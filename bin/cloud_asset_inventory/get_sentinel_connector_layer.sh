#!/bin/bash

aws lambda get-layer-version-by-arn \
--region ca-central-1 \
--arn arn:aws:lambda:ca-central-1:283582579564:layer:aws-sentinel-connector-layer:6 \
| jq -r '.Content.Location' \
| xargs curl -o ../../images/cloud_asset_inventory/sentinel_neo4j_forwarder/connector.zip