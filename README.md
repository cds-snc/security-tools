# Security Tools
La version française sera disponible bientôt

## Description

This repository will contain various tools used by CDS to ensure the confidentiality, integrity and availability of CDS applications and services.

## Services

- Cloud Asset Inventory: AWS, ECS, [CloudQuery](https://www.cloudquery.io/docs)
- Content Security Policy (CSP) violation reporting: AWS, Lambda
  - Onboard by adding the `report-uri https://csp-report-to.security.cdssandbox.xyz/report;` directive to your apps existing CSP
- CCCS Cloud Control Issue Generator

## Interactive Neo4j access

The SSO proxy is for occasional troubleshooting through Neo4j Browser. It is not
part of the scheduled Cartography scan/export pipeline: Cartography connects to
Neo4j through the internal NLB, exports to S3, and the Sentinel forwarding
workflow reads those S3 objects directly.

The existing public ALB terminates TLS and routes two hostnames to oauth2-proxy
containers in a single private Fargate task:

- `neo4j.security.cdssandbox.xyz` -> proxy port 4180 -> internal Neo4j HTTP.
- `bolt.security.cdssandbox.xyz` -> proxy port 4181 -> internal Bolt WebSockets.
- `auth.security.cdssandbox.xyz/oauth2/callback` -> the first proxy's Google callback.

Both deployed images use `repository@sha256:...` references. Terragrunt reads the
digest from [images/mirror.json](images/mirror.json), which is the source of truth
for the mirrored image. Version tags are mirroring labels only; changing a tag
cannot change the image selected by an existing task definition.

Both containers share a secure, HttpOnly, SameSite=Lax domain cookie, an eight-hour
session lifetime, and hourly session refresh. Only `cds-snc.ca` Google accounts
are permitted. Open <https://neo4j.security.cdssandbox.xyz>, sign in with Google,
then authenticate with the existing Neo4j database credentials. The proxy does
not replace Neo4j authentication or support public native Bolt/TCP connections.
Unauthenticated Bolt requests return 401; sign in through the Browser first.

To clear the proxy session, visit
<https://auth.security.cdssandbox.xyz/oauth2/sign_out>. This does not sign you out
of Google or revoke an already-open WebSocket; close the Browser connection too.
Session expiry is checked on new requests/connection upgrades, not continuously
on an established WebSocket.

### Migrating from Pomerium

This is a direct swap with brief interactive-access downtime; existing Pomerium
sessions are not retained. Scheduled scans and S3 exports are unchanged.

1. Keep the existing Google OAuth client and repository secrets
   `POMERIUM_GOOGLE_CLIENT_ID` and `POMERIUM_GOOGLE_CLIENT_SECRET`. Add this
   authorized redirect URI to the Google client:
   `https://auth.security.cdssandbox.xyz/oauth2/callback`.
2. Generate a new cookie secret using `openssl rand -base64 32` and save it as
   the GitHub Actions secret `OAUTH2_PROXY_COOKIE_SECRET`. Do not commit it.
3. Merge the infrastructure/image changes. Wait for the base apply workflow to
   publish `oauth2_proxy_repository_url` and for the image-mirroring workflow to
   publish the pinned image from [images/mirror.json](images/mirror.json). The
   proxy uses generic SSO proxy names for its new AWS resources. The old ECR
   repository is left in place, outside Terraform state, for rollback.
4. Run the **Terragrunt plan sso proxy** workflow and review the plan. Expect
   replacement of the ALB, security groups, IAM roles, proxy service/task/log
   group, and SSM parameters; new proxy target groups; and DNS/WAF association
   updates. Neo4j, Cartography schedule, and export bucket must remain.
5. Merge the reviewed infrastructure/image changes to `main` to run
   **Terragrunt apply sso proxy**. The workflow checks that the required secrets
   are set and that the mirrored ECR image digest matches the manifest before
   applying.
6. Verify both ALB target groups become healthy, sign in to Neo4j Browser, and
   execute `RETURN 1` over the advertised secure Bolt WebSocket endpoint. Verify
   a non-`cds-snc.ca` account is denied and a logged-out Bolt request returns 401.
   Check proxy logs under `/aws/ecs/oauth2_proxy` and confirm the next scheduled
   export and Sentinel forwarding run succeed.

After verification, remove unused GitHub secrets `POMERIUM_CLIENT_ID`,
`POMERIUM_CLIENT_SECRET`, `SESSION_KEY`, and `SESSION_COOKIE_SECRET`, and remove
the obsolete Pomerium callback URI from the Google client.

For recovery, retain the pre-migration Git revision, the old ECR repository and
Pomerium image's existing `latest` tag, and old GitHub secrets until verification
completes. The new SSO proxy image uses a separate ECR repository, so the old one
is not overwritten. Restoring the previous proxy Terraform configuration and
applying it recreates its service and SSM parameters. Keep the new Google callback
while restoring the old one if needed. After the rollback window closes, remove
the old ECR repository manually.

## License

This code is released under the MIT License. See [LICENSE](LICENSE).

## Maintenance

_Note: If you are using Codespaces, all the environment setup is done for you. You can start working on the Cloud Asset Inventory right away._

See the Makefile for the available commands.

Main commands:

- **build**: Build the Docker image for the Cloud Asset Inventory in Codespaces using docker-compose (sets up the environment for network analysis and other resources)
- **start**: Start the Docker container for the Cloud Asset Inventory in Codespaces
- **start-logging**: Start the Docker container for the Cloud Asset Inventory in Codespaces with network logging enabled (using tcpdump)
- **attach**: Attach a shell to the running Docker container for the Cloud Asset Inventory in Codespaces
- **stop**: Stop the Docker container for the Cloud Asset Inventory in Codespaces
- **copy-logs**: Copy the network logs and the Cloud Asset Inventory logs from the Docker container to the host machine
- **copy-data**: Copy the data generated by the Cloud Asset Inventory from the Docker container to the host machine
- **delete-logs**: Delete the network logs from the Docker container
