Multiple AWS Account Setup
There are many ways to allow Cartography to pull from more than one AWS account. The recommended pattern is to configure one named AWS profile per account in ~/.aws/config and run Cartography with --aws-sync-all-profiles.

If you want AWS Organizations hierarchy data, include a profile for the Organizations management account or a delegated administrator account. For large environments, pass that account ID with --aws-organization-account-ids so Cartography can sync Organizations once without probing every configured profile.

cartography \
  --neo4j-uri bolt://localhost:7687 \
  --aws-sync-all-profiles \
  --aws-organization-account-ids 123456789012
If you omit --aws-organization-account-ids, Cartography will use DescribeOrganization against the configured profiles to find candidate accounts, prefer the management account when it is present, and then try to sync the hierarchy. This fallback is useful for small environments and ad hoc runs, but explicit organization account IDs are more predictable at scale.

In this example, we will assume that you are going to run Cartography on an EC2 instance.

Pick one of your AWS accounts to be the “Hub” account. This Hub account will pull data from all of your other accounts - we’ll call those “Spoke” accounts.

Set up the IAM roles: Create an IAM role named cartography-read-only on all of your accounts. Configure the role on all accounts as follows:

Attach the built-in AWS SecurityAudit IAM policy (arn:aws:iam::aws:policy/SecurityAudit) to the role. This grants access to read security config metadata.

Set up a trust relationship so that the Spoke accounts will allow the Hub account to assume the cartography-read-only role. The resulting trust relationship should look something like this:

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::<Hub's account number>:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
Allow a role in the Hub account to assume the cartography-read-only role on your Spoke account(s).

On the Hub account, create a role called cartography-service.

On this new cartography-service role, add an inline policy with the following JSON:

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": "arn:aws:iam::*:role/cartography-read-only",
      "Action": "sts:AssumeRole"
    },
	{
	  "Effect": "Allow",
	  "Action": "ec2:DescribeRegions",
	  "Resource": "*"
	}
  ]
}
This allows the Hub role to assume the cartography-read-only role on your Spoke accounts and to fetch all the different regions used by the Spoke accounts.

When prompted to name the policy, you can name it anything you want - perhaps CartographyAssumeRolePolicy.

Set up your EC2 instance to correctly access these AWS identities

Attach the cartography-service role to the EC2 instance that you will run Cartography on. You can do this by following these official AWS steps.

Ensure that the [default] profile in your AWS_CONFIG_FILE file (default ~/.aws/config in Linux, and %UserProfile%\.aws\config in Windows) looks like this:

 [default]
 region=<the region of your Hub account, e.g. us-east-1>
 output=json
Add a profile for each AWS account you want Cartography to sync with to your AWS_CONFIG_FILE. It will look something like this:

[profile accountname1]
role_arn = arn:aws:iam::<AccountId#1>:role/cartography-read-only
region=us-east-1
output=json
credential_source = Ec2InstanceMetadata

[profile accountname2]
role_arn = arn:aws:iam::<AccountId#2>:role/cartography-read-only
region=us-west-1
output=json
credential_source = Ec2InstanceMetadata

... etc ...
[Optional] Configure Cartography’s shared AWS client retry behavior with:

CARTOGRAPHY_AWS_RETRY_MODE

CARTOGRAPHY_AWS_MAX_ATTEMPTS

CARTOGRAPHY_AWS_READ_TIMEOUT Default values and behavior are described in the single-account setup section above. These Cartography env vars control the botocore config objects Cartography builds for AWS clients.

[Optional] Use regional STS endpoints to avoid InvalidToken errors when assuming roles across regions. Add sts_regional_endpoints = regional to your AWS config file or set the AWS_STS_REGIONAL_ENDPOINTS=regional environment variable. AWS Docs.

AWS Organizations Behavior
AWS Organizations sync is separate from per-account resource sync. It models the organization, root, organizational units, and account placement before Cartography syncs normal account-scoped resources.

Configuration

Organizations behavior

Account resource sync

Single-account credentials

Attempts Organizations sync with the current credentials. If the account cannot enumerate the hierarchy, Organizations cleanup is skipped.

Syncs the current account.

--aws-sync-all-profiles --aws-organization-account-ids <account-id>

Probes only the specified Organizations sync candidate IDs, groups them by organization, prefers the management account when present, and tries candidates until one syncs each organization.

Syncs each configured profile/account.

--aws-sync-all-profiles without organization account IDs

Probes configured profiles with DescribeOrganization, groups candidates by organization, prefers the management account when present, and tries candidates until one syncs each organization.

Syncs each configured profile/account.

No usable Organizations-enumerating account

Skips Organizations hierarchy writes and cleanup to preserve prior hierarchy data.

Continues account resource sync.

AWS’s managed SecurityAudit policy currently includes organizations:Describe* and organizations:List*, but the policy alone is not enough for full hierarchy enumeration. AWS Organizations allows DescribeOrganization from any member account, while hierarchy APIs such as ListRoots, ListAccountsForParent, and ListOrganizationalUnitsForParent require the management account or a delegated administrator account. Cartography only runs Organizations hierarchy cleanup after a complete hierarchy enumeration.

---

Here’s a detailed plan and file-level diff for updating your repo to use the official CNCF Cartography image in ECS, with multi-account support as described in your attached guide.

---

# 1. Directory Structure Changes

**No major new directories are needed.**  
You will mainly update:
- cartography (remove custom Dockerfile/entrypoint)
- cloud_asset_inventory (update ECS task definition, IAM roles, config handling)
- Possibly add a config file for AWS profiles if you want to inject it into the container.

---

# 2. File-Level Changes

## A. images/cloud_asset_inventory/cartography

### Remove custom Dockerfile and entrypoint

**Delete:**
- Dockerfile
- docker-entrypoint.sh
- requirements.txt
- requirements.in
- README.md

**Keep:** (if you want to keep for reference, move to an `archive/` folder)

---

## B. terragrunt/aws/cloud_asset_inventory

### 1. Update ECS Task Definition

**Edit:** ecs.tf (or wherever your ECS task/service is defined)

**Replace the container image and entrypoint/command:**
```hcl
container_definitions = jsonencode([
  {
    name      = "cartography"
    image     = "ghcr.io/cncf/cartography:latest"
    essential = true
    environment = [
      { name = "NEO4J_URI", value = "bolt://<neo4j-host>:7687" },
      { name = "NEO4J_USER", value = "<user>" },
      { name = "NEO4J_PASSWORD", value = "<password>" },
      # Optionally: { name = "AWS_STS_REGIONAL_ENDPOINTS", value = "regional" }
      # Optionally: { name = "CARTOGRAPHY_AWS_RETRY_MODE", value = "standard" }
      # Optionally: { name = "CARTOGRAPHY_AWS_MAX_ATTEMPTS", value = "10" }
      # Optionally: { name = "CARTOGRAPHY_AWS_READ_TIMEOUT", value = "60" }
    ]
    mountPoints = [
      {
        sourceVolume  = "aws-config"
        containerPath = "/root/.aws"
        readOnly      = true
      }
    ]
    command = [
      "--neo4j-uri", "$(NEO4J_URI)",
      "--neo4j-user", "$(NEO4J_USER)",
      "--neo4j-password", "$(NEO4J_PASSWORD)",
      "--aws-sync-all-profiles",
      "--aws-organization-account-ids", "<hub-account-id>"
    ]
    logConfiguration = {
      # ...existing log config...
    }
  }
])
```
- **Remove any custom entrypoint or script references.**
- **Mount an EFS volume or inject a config file for `/root/.aws/config` and `/root/.aws/credentials`** (see below).

---

### 2. Add EFS Volume for AWS Config (if not already present)

**Edit:** efs.tf (or similar)

- Create an EFS volume and mount it to `/root/.aws` in the container.
- Place your multi-profile `config` and `credentials` files there, as described in your guide.

---

### 3. IAM Role Updates

**Edit:** iam.tf

- The ECS task role should have:
  - `sts:AssumeRole` on all `cartography-read-only` roles in your org.
  - `ec2:DescribeRegions`
- Example:
```hcl
resource "aws_iam_role" "cartography_service" {
  name = "cartography-service"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role_policy.json
  # ...existing...
}

resource "aws_iam_role_policy" "cartography_assume" {
  name = "CartographyAssumeRolePolicy"
  role = aws_iam_role.cartography_service.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Resource = "arn:aws:iam::*:role/cartography-read-only"
      },
      {
        Effect = "Allow"
        Action = "ec2:DescribeRegions"
        Resource = "*"
      }
    ]
  })
}
```
- Attach this role to your ECS task.

---

### 4. AWS Config File

**Create or update:**  
- `/efs/aws-config/config` (or wherever you mount as `/root/.aws/config` in the container)

**Example:**
```
[default]
region=ca-central-1
output=json

[profile account1]
role_arn = arn:aws:iam::<AccountId1>:role/cartography-read-only
region=ca-central-1
output=json
credential_source = EcsContainer

[profile account2]
role_arn = arn:aws:iam::<AccountId2>:role/cartography-read-only
region=us-west-2
output=json
credential_source = EcsContainer
```
- Repeat for all accounts.
- If you use `credentials` file, it can be empty if you rely on ECS credentials.

---

### 5. Remove Old Image Build Resources

- Remove any ECR repository, build pipeline, or references to the old custom Cartography image.

---

# 3. Summary Table of Changes

| Path                                                      | Action         | Notes                                                                 |
|-----------------------------------------------------------|----------------|-----------------------------------------------------------------------|
| images/cloud_asset_inventory/cartography/Dockerfile       | Delete         | Use official image                                                    |
| docker-entrypoint.sh | Delete     | Use official image                                                    |
| requirements.txt  | Delete         | Use official image                                                    |
| requirements.in   | Delete         | Use official image                                                    |
| README.md         | Delete         | Use official image                                                    |
| ecs.tf                | Update         | Use official image, update env, command, mount AWS config             |
| efs.tf                | Update/Create  | Ensure EFS volume for AWS config                                      |
| iam.tf                | Update         | Update ECS task role for multi-account assume role                    |
| efs/aws-config/config (or similar)                        | Add/Update     | Multi-profile AWS config as per guide                                 |
| ECR resources for old image                               | Delete         | Not needed if using official image                                    |

---

# 4. Example: Minimal New ECS Task Definition (HCL)

```hcl
resource "aws_ecs_task_definition" "cartography" {
  family                   = "cartography"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.cartography_service.arn

  container_definitions = jsonencode([
    {
      name      = "cartography"
      image     = "ghcr.io/cncf/cartography:latest"
      essential = true
      environment = [
        { name = "NEO4J_URI", value = "bolt://<neo4j-host>:7687" },
        { name = "NEO4J_USER", value = "<user>" },
        { name = "NEO4J_PASSWORD", value = "<password>" }
      ]
      mountPoints = [
        {
          sourceVolume  = "aws-config"
          containerPath = "/root/.aws"
          readOnly      = true
        }
      ]
      command = [
        "--neo4j-uri", "$(NEO4J_URI)",
        "--neo4j-user", "$(NEO4J_USER)",
        "--neo4j-password", "$(NEO4J_PASSWORD)",
        "--aws-sync-all-profiles",
        "--aws-organization-account-ids", "<hub-account-id>"
      ]
      logConfiguration = {
        # ...existing log config...
      }
    }
  ])

  volume {
    name = "aws-config"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.aws_config.id
      root_directory = "/"
    }
  }
}
```

---

# 5. What to Remove

- All custom Cartography Docker build logic and scripts.
- Any ECR resources for the old image.
- Any ECS task definition logic that references the old image or custom entrypoint.

---

# 6. What to Add/Update

- Use the official Cartography image in ECS.
- Mount a shared AWS config (multi-profile) into the container.
- Update IAM roles for multi-account assume role.
- Pass Neo4j and other config via environment variables.
- Use ECS credentials (`credential_source = EcsContainer`) in AWS config.