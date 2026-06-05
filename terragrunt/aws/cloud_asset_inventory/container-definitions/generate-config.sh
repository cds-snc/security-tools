#!/bin/sh
# Generates an AWS CLI config with one profile per ACTIVE AWS Organizations
# account, for Cartography's --aws-sync-all-profiles. Run by the init container.
#
# The management account profile uses ORG_LIST_ROLE_ARN (which can also enumerate
# the org hierarchy); every other account uses the spoke audit role. Each profile
# uses credential_source = EcsContainer so it assumes its target role with the
# task role's credentials from the Fargate container credentials endpoint.
#
# Required environment:
#   ORG_LIST_ROLE_ARN - role in the management account assumed for org enumeration
#   MGMT_ACCOUNT_ID    - management account ID
#   SPOKE_ROLE_NAME    - read-only role assumed in each member account
#   AWS_REGION         - region for the generated profiles
#   CONFIG_PATH        - output path (default /config/role_config)
set -eu

: "${ORG_LIST_ROLE_ARN:?ORG_LIST_ROLE_ARN is required}"
: "${MGMT_ACCOUNT_ID:?MGMT_ACCOUNT_ID is required}"
: "${SPOKE_ROLE_NAME:?SPOKE_ROLE_NAME is required}"
: "${AWS_REGION:?AWS_REGION is required}"
CONFIG_PATH="${CONFIG_PATH:-/config/role_config}"

echo "Assuming ${ORG_LIST_ROLE_ARN} to enumerate AWS Organizations accounts..."
creds=$(aws sts assume-role \
  --role-arn "${ORG_LIST_ROLE_ARN}" \
  --role-session-name cartography-list \
  --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
  --output text)

# Split the tab-separated credentials into positional parameters (word splitting
# is intentional here).
# shellcheck disable=SC2086
set -- $creds

accounts=$(
  AWS_ACCESS_KEY_ID="$1" \
    AWS_SECRET_ACCESS_KEY="$2" \
    AWS_SESSION_TOKEN="$3" \
    aws organizations list-accounts \
    --query 'Accounts[?Status==`ACTIVE`].Id' \
    --output text
)

{
  printf '[default]\nregion = %s\noutput = json\nsts_regional_endpoints = regional\n' "${AWS_REGION}"
  # Word splitting of the whitespace-separated account list is intentional.
  # shellcheck disable=SC2086
  for acct in ${accounts}; do
    printf '\n[profile %s]\nregion = %s\noutput = json\nsts_regional_endpoints = regional\ncredential_source = EcsContainer\n' "${acct}" "${AWS_REGION}"
    if [ "${acct}" = "${MGMT_ACCOUNT_ID}" ]; then
      printf 'role_arn = %s\n' "${ORG_LIST_ROLE_ARN}"
    else
      printf 'role_arn = arn:aws:iam::%s:role/%s\n' "${acct}" "${SPOKE_ROLE_NAME}"
    fi
  done
} >"${CONFIG_PATH}"

echo "Wrote $(grep -c '^\[profile' "${CONFIG_PATH}") account profiles to ${CONFIG_PATH}"
