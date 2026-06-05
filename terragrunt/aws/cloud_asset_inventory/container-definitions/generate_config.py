#!/usr/bin/env python3
"""Generate an AWS CLI config with one profile per ACTIVE AWS Organizations
account, for Cartography's --aws-sync-all-profiles.

Runs in the init container using the cartography image (which already ships
boto3), so no separate/public image is needed. The management account profile
uses ORG_LIST_ROLE_ARN (which can also enumerate the org hierarchy); every other
account uses the spoke audit role. Each profile uses credential_source =
EcsContainer so it assumes its target role with the task role's credentials from
the Fargate container credentials endpoint.

Required environment:
  ORG_LIST_ROLE_ARN - role in the management account assumed for org enumeration
  MGMT_ACCOUNT_ID    - management account ID
  SPOKE_ROLE_NAME    - read-only role assumed in each member account
  AWS_REGION         - region for the generated profiles
  CONFIG_PATH        - output path (default /config/role_config)
"""
import glob
import os
import sys

# boto3 ships inside the cartography image's uv-managed tool environment, not on
# the system python3's path. Add that environment's site-packages (resolved with
# globs so we don't hardcode the python version or uv's internal layout) so this
# script can import boto3 without needing a separate image.
for _pattern in (
    "/var/cartography/.local/share/uv/tools/*/lib/python*/site-packages",
    "/var/cartography/.local/lib/python*/site-packages",
):
    sys.path[:0] = glob.glob(_pattern)

import boto3  # noqa: E402  (imported after the sys.path bootstrap above)


def require(name):
    value = os.environ.get(name)
    if not value:
        sys.exit(f"{name} is required")
    return value


def main():
    org_list_role_arn = require("ORG_LIST_ROLE_ARN")
    mgmt_account_id = require("MGMT_ACCOUNT_ID")
    spoke_role_name = require("SPOKE_ROLE_NAME")
    region = require("AWS_REGION")
    config_path = os.environ.get("CONFIG_PATH", "/config/role_config")

    print(f"Assuming {org_list_role_arn} to enumerate AWS Organizations accounts...")
    creds = boto3.client("sts", region_name=region).assume_role(
        RoleArn=org_list_role_arn,
        RoleSessionName="cartography-list",
    )["Credentials"]

    org = boto3.client(
        "organizations",
        region_name=region,
        aws_access_key_id=creds["AccessKeyId"],
        aws_secret_access_key=creds["SecretAccessKey"],
        aws_session_token=creds["SessionToken"],
    )

    accounts = [
        account["Id"]
        for page in org.get_paginator("list_accounts").paginate()
        for account in page["Accounts"]
        if account["Status"] == "ACTIVE"
    ]

    lines = ["[default]", f"region = {region}", "output = json", "sts_regional_endpoints = regional"]
    for account_id in accounts:
        role_arn = (
            org_list_role_arn
            if account_id == mgmt_account_id
            else f"arn:aws:iam::{account_id}:role/{spoke_role_name}"
        )
        lines += [
            "",
            f"[profile {account_id}]",
            f"region = {region}",
            "output = json",
            "sts_regional_endpoints = regional",
            "credential_source = EcsContainer",
            f"role_arn = {role_arn}",
        ]

    with open(config_path, "w", encoding="utf-8") as config_file:
        config_file.write("\n".join(lines) + "\n")

    print(f"Wrote {len(accounts)} account profiles to {config_path}")


if __name__ == "__main__":
    main()
