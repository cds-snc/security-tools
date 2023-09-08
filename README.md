# Security Tools
La version française sera disponible bientôt

## Description

This repository will contain various tools used by CDS to ensure the confidentiality, integrity and availability of CDS applications and services.

## Services

- Cloud Asset Inventory: AWS, ECS, [CloudQuery](https://www.cloudquery.io/docs)
- Content Security Policy (CSP) violation reporting: AWS, Lambda
   - Onboard by adding the `report-uri https://csp-report-to.security.cdssandbox.xyz/report;` directive to your apps existing CSP

## License

This code is released under the MIT License. See [LICENSE](LICENSE).

## Maintenance

### Upgrading CloudQuery

1. Update the `cloudquery` image tag in `Dockerfile` to the latest version (path: /workspace/images/cloud_asset_inventory/cloudquery/Dockerfile)
2. In VS Code, run the devcontainer to build the new image and start the container
3. Assume the PlatformSecurity role in the AWS account you want to scan and export the credentials to your environment
4. Export the CQ_S3_BUCKET variable to your environment with the name cloudquery-794722365809-test as the value (ex: `export CQ_S3_BUCKET=cloudquery-794722365809-test`)
4. Run `make build-cq` to build the CloudQuery binary
5. Run `make run-cloud-query` to run the CloudQuery container

