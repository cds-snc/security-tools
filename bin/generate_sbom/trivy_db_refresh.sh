#!/bin/bash

#
# Attempts to refresh the Trivy Database in the specified target repository.
# Uses backoff strategy to retry on failure since there have been intermittent rate
# limiting issues with the source ECR public registry.
#
# This script expects that ECR authentication has already been performed.
#

target_repo="$1"
max_attempts=5
attempt=0
backoff=1

while [ $attempt -lt $max_attempts ]; do
    if oras cp public.ecr.aws/aquasecurity/trivy-db:latest "$target_repo"; then
        echo "Trivy Database refreshed successfully."
        break
    else
        attempt=$((attempt + 1))
        echo "Attempt $attempt failed. Retrying in $backoff seconds..."
        sleep $backoff
        backoff=$((backoff * 2))
    fi
done

if [ $attempt -eq $max_attempts ]; then
    echo "Failed to refresh Trivy Database after $max_attempts attempts."
    exit 1
fi