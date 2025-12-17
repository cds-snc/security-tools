#!/bin/bash

#
# Attempts to refresh the Trivy Database in the specified target repository.
# Uses backoff strategy to retry on failure since there have been intermittent rate
# limiting issues with the source ECR public registry.
#
# This script expects that ECR authentication has already been performed.
#

trivy_db_name="$1"
target_repo="$2"
max_attempts=5
attempt=0
backoff=1

while [ $attempt -lt $max_attempts ]; do
    if oras cp public.ecr.aws/aquasecurity/$trivy_db_name "$target_repo"; then
        echo "$trivy_db_name refreshed successfully."
        break
    else
        attempt=$((attempt + 1))
        echo "Attempt $attempt failed. Retrying in $backoff seconds..."
        sleep $backoff
        backoff=$((backoff * 2))
    fi
done

if [ $attempt -eq $max_attempts ]; then
    echo "Failed to refresh $trivy_db_name database after $max_attempts attempts."
    exit 1
fi

# Delete untagged images from the repository since it is nearly the end of 2025
# but for some reason public ECRs still do not support lifecycle policies.
repository_name=$(echo "$target_repo" | sed -E 's|^public\.ecr\.aws/[^/]+/||; s|:.*$||')
echo "Cleaning up untagged images from $repository_name..."
UNTAGGED_IMAGES=$(aws ecr-public describe-images \
  --repository-name "$repository_name" \
  --query 'imageDetails[?imageTags==`null`].imageDigest' \
  --region us-east-1 \
  --output text)

if [ -n "$UNTAGGED_IMAGES" ]; then
    IMAGE_IDS=""
    for digest in $UNTAGGED_IMAGES; do
        IMAGE_IDS="$IMAGE_IDS imageDigest=$digest"
    done
    echo "Deleting untagged images... $IMAGE_IDS"
    aws ecr-public batch-delete-image \
      --repository-name "$repository_name" \
      --image-ids $IMAGE_IDS \
      --region us-east-1
    echo "Deleted untagged images from $repository_name"
else
    echo "No untagged images to delete from $repository_name"
fi