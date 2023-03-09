#!/bin/sh


# Setup AWS credentials for the Docker container


if [ -z "$LOCAL" ]; then 
    echo "Running in AWS ECS"

  # Setup AWS credentials for the Docker container

  mkdir -p ~/.aws/
  curl -sqL -o aws_credentials.json http://169.254.170.2/$AWS_CONTAINER_CREDENTIALS_RELATIVE_URI > aws_credentials.json

  cat <<EOF >> /config/role_config
[profile $AWS_ACCOUNT]
role_arn = arn:aws:iam::$AWS_ACCOUNT:role/secopsAssetInventorySecurityAuditRole
source_profile = default
region = ca-central-1
output = json

[default]
region = ca-central-1
output=json
aws_access_key_id=$(jq -r '.AccessKeyId' aws_credentials.json)
aws_secret_access_key=$(jq -r '.SecretAccessKey' aws_credentials.json)
aws_session_token=$(jq -r '.Token' aws_credentials.json)
EOF

else

  echo "Running locally"

  mkdir -p ~/.aws/config/
  cat <<EOF >> /config/role_config

[profile $AWS_ACCOUNT]
source_profile = default
region = ca-central-1
output = json
aws_access_key_id=$AWS_ACCESS_KEY_ID
aws_secret_access_key=$AWS_SECRET_ACCESS_KEY
aws_session_token=$AWS_SESSION_TOKEN

EOF

fi

echo "AWS configuration complete, launching cartography"

cartography --neo4j-uri "$NEO4J_URI" \
  --neo4j-user "$NEO4J_USER" \
  --neo4j-password-env-var NEO4J_SECRETS_PASSWORD \
  --aws-sync-all-profiles \
  --aws-best-effort-mode

exit 0