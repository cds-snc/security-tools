# Security Tools
La version française sera disponible bientôt

## Description

This repository will contain various tools used by CDS to ensure the confidentiality, integrity and availability of CDS applications and services.

## Services

- SSO Proxy : AWS, ECS, Google SSO, [Pomerium](https://github.com/pomerium/pomerium)
- Cloud Asset Inventory: AWS, ECS, [CloudQuery](https://www.cloudquery.io/docs)
- [Content Security Policy (CSP) violation reporting](https://csp-reports.security.cdssandbox.xyz/): AWS, ECS, RDS
   - Onboard by adding the `report-uri https://csp-report-to.security.cdssandbox.xyz/report;` directive to your apps existing CSP

## License

This code is released under the MIT License. See [LICENSE](LICENSE).
