# Deployment Runbook

Step-by-step guide for deploying `terraform-aws-webapp-foundation` to a new AWS account or environment.

## Prerequisites

| Tool          | Minimum Version | Purpose                     |
| ------------- | --------------- | --------------------------- |
| Terraform     | 1.5.0           | Infrastructure provisioning |
| AWS CLI       | 2.x             | Credential configuration    |
| Git           | 2.x             | Source control               |
| curl          | any             | Smoke check validation       |
| make          | any             | Workflow shortcuts           |

Ensure your AWS CLI profile is configured and has sufficient IAM permissions to create VPCs, EC2 instances, RDS instances, S3 buckets, and DynamoDB tables.

## Step 1 — Clone the Repository

```bash
git clone https://github.com/VietSory/terraform-aws-webapp-foundation.git
cd terraform-aws-webapp-foundation
```

## Step 2 — Bootstrap Remote State

Each environment needs its own state backend created before the webapp stack can be initialized.

```bash
# Dev environment
make bootstrap-init ENV=dev
make bootstrap-plan ENV=dev      # Review planned resources
make bootstrap-apply ENV=dev     # Create S3 bucket + DynamoDB table
```

After apply, note the output values for:
- `state_bucket_name`
- `lock_table_name`

## Step 3 — Configure Backend

Copy the backend config example and fill in the real values from Step 2:

```bash
cd live/dev/webapp
cp backend.hcl.example backend.hcl
```

Edit `backend.hcl`:

```hcl
bucket         = "<state_bucket_name from Step 2>"
key            = "environments/dev/webapp/terraform.tfstate"
region         = "ap-southeast-1"
profile        = "default"
encrypt        = true
dynamodb_table = "<lock_table_name from Step 2>"
```

Return to the repository root:

```bash
cd ../../..
```

## Step 4 — Review Variables

Review and adjust the variable file for your environment:

```bash
# Dev uses the checked-in defaults
cat live/dev/webapp/tfvars/dev.tfvars

# Prod has a separate baseline
cat live/prod/webapp/tfvars/prod.tfvars
```

Key variables to review:
- `aws_region` and `aws_profile` — must match your AWS CLI setup
- `vpc_cidr` and subnet CIDRs — avoid overlapping with existing VPCs
- `ec2_instance_type` / `rds_instance_class` — adjust for cost or performance
- RDS lifecycle flags — `rds_deletion_protection`, `rds_skip_final_snapshot`

## Step 5 — Deploy the Webapp Stack

```bash
# Initialize with the backend configuration
make webapp-init ENV=dev

# Preview the infrastructure changes
make webapp-plan ENV=dev

# Apply the changes (requires confirmation)
make webapp-apply ENV=dev
```

Expected resources created:
- 1 VPC with subnets, internet gateway, and route tables
- 2 security groups (web and database)
- 1 EC2 instance serving an HTTP landing page
- 1 RDS MySQL instance in a DB subnet group
- 1 S3 bucket for static assets

## Step 6 — Validate the Deployment

### Automated smoke check

```bash
make smoke ENV=dev
```

The smoke check script verifies:
1. Terraform outputs are populated (`website_url`, `static_assets_bucket`, `rds_endpoint`)
2. Expected resources exist in Terraform state
3. The website URL responds with HTTP 200 and contains expected content

### Manual verification

```bash
cd live/dev/webapp

# Show all outputs
terraform output

# Test the website
curl "$(terraform output -raw website_url)"

# List managed resources
terraform state list
```

## Step 7 — Deploy to Production

Repeat Steps 2–6 with `ENV=prod`:

```bash
make bootstrap-init ENV=prod
make bootstrap-apply ENV=prod

# Configure live/prod/webapp/backend.hcl (same process as Step 3)

make webapp-init ENV=prod
make webapp-plan ENV=prod
make webapp-apply ENV=prod
make smoke ENV=prod
```

> **Important:** Review the prod variable file carefully before applying. Prod enables deletion protection and multi-AZ, which affect cost and teardown procedures.

## Teardown

### Dev environment (designed for fast cleanup)

```bash
make webapp-destroy ENV=dev
```

Dev defaults allow clean teardown: `skip_final_snapshot = true`, `force_destroy = true`, `deletion_protection = false`.

### Prod environment (protected)

Before destroying prod, you must:

1. Disable RDS deletion protection via the AWS Console or by setting `rds_deletion_protection = false` and applying
2. The final RDS snapshot will be created automatically (`skip_final_snapshot = false`)
3. S3 bucket must be emptied manually if `force_destroy = false`

```bash
# After disabling protections:
make webapp-destroy ENV=prod
```

## Troubleshooting

| Problem                                    | Solution                                                             |
| ------------------------------------------ | -------------------------------------------------------------------- |
| `terraform init` fails with backend error  | Ensure `backend.hcl` exists and contains valid bucket/table names    |
| EC2 instance unreachable                   | Check security group allows TCP 80 inbound; verify subnet has IGW    |
| RDS connection refused from EC2            | Confirm DB SG allows 3306 from the web security group                |
| `make smoke` fails on HTTP check           | Wait 2–3 minutes after apply for EC2 user data to complete           |
| State lock error                           | Another `terraform apply` may be running; check DynamoDB lock table  |
| Destroy fails on RDS                       | Disable deletion protection first, then retry                        |

## Operational Notes

- **State files** are stored in S3 with encryption enabled and DynamoDB locking
- **Tags** are applied automatically via provider default tags (Project, Environment, Repository, Stack, Component, ManagedBy)
- **Naming convention** follows `{project_name}-{environment}` prefix for all resources
- **CI checks** run on every push and PR via GitHub Actions (format, validate, lint, security scan)
