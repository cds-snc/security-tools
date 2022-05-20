#!/bin/bash
IFS=$'\n\t'

#
# PURPOSE:
# Bootstraps a given account's IAM roles for onboarding to retrieve asset inventory.
# This is based on which account has AWS SSO to a AdministratorAccess role
#
# REQUIREMENTS:
# - AWS CLI
# - AWS SSO Util; https://pypi.org/project/aws-sso-util/
# ENVIRONMENT:
# - AWS_DEFAULT_SSO_START_URL: "https://[directory].awsapps.com/start", where [directory] is the AWS SSO directory
# USE:
# ./bootstrap_iam_using_sso.sh 
#

# Setup profiles for all accounts that you have access to
aws-sso-util configure populate --region ca-central-1

ACCOUNT_LIST="$(aws configure list-profiles)"
SECURITY_AUDIT_ROLE_NAME="secopsAssetInventorySecurityAuditRole"
ASSET_INVENTORY_ROLE_NAME="secopsAssetInventoryCartographyRole"
SECURITY_ACCOUNT_ID="794722365809"

ASSUME_ROLE_POLICY_DOCUMENT=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com",
          "ecs-tasks.amazonaws.com"
        ],
        "AWS": "arn:aws:iam::$SECURITY_ACCOUNT_ID:role/$ASSET_INVENTORY_ROLE_NAME"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
)

while IFS= read -r AWS_PROFILE
do
  if [[ "$AWS_PROFILE" == *".AdministratorAccess"* ]]; then
    echo -e "\033[0;33m⚡\033[0m Onboard account \033[0;35m$AWS_PROFILE\033[0m"
    ASSUMED_ROLE="$(aws --profile $AWS_PROFILE sts get-caller-identity | jq -r '.Arn')"
    echo -e "\033[0;32m✔\033[0m Assumed role via SSO: $ASSUMED_ROLE"
    ROLE_EXISTS="$(aws --profile $AWS_PROFILE iam get-role --role-name $SECURITY_AUDIT_ROLE_NAME --output text 2>&1)"
    if [[ "$ROLE_EXISTS" == *"NoSuchEntity"* ]]; then
      echo -e "\033[0;32m✔\033[0m $SECURITY_AUDIT_ROLE_NAME doesn't exist, creating"
      aws --profile $AWS_PROFILE iam create-role --role-name $SECURITY_AUDIT_ROLE_NAME --assume-role-policy-document "$ASSUME_ROLE_POLICY_DOCUMENT" > /dev/null 2>&1
      aws --profile $AWS_PROFILE iam wait role-exists --role-name $SECURITY_AUDIT_ROLE_NAME
    fi
    echo -e "\033[0;32m✔\033[0m Attaching policies to $SECURITY_AUDIT_ROLE_NAME"
    aws --profile $AWS_PROFILE iam update-assume-role-policy --role-name $SECURITY_AUDIT_ROLE_NAME --policy-document "$ASSUME_ROLE_POLICY_DOCUMENT" > /dev/null 2>&1
    aws --profile $AWS_PROFILE iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/SecurityAudit --role-name $SECURITY_AUDIT_ROLE_NAME
    sleep 1
  fi
   
done < <(printf '%s\n' "$ACCOUNT_LIST")