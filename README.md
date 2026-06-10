# Terraform AWS Webapp Foundation

## Overview

`terraform-aws-webapp-foundation` is a modular Terraform repository for bootstrapping and deploying a small AWS web application stack. It separates backend-state provisioning from application infrastructure so the stack can be reused across accounts and environments.

This repository currently provisions:

- Terraform remote state infrastructure with S3 and DynamoDB
- Reusable Terraform modules for networking, security, compute, database, and storage
- A VPC with one public subnet and two private database subnets
- Security groups for a public web tier and private MySQL tier
- An EC2 instance that serves a simple HTTP landing page
- A private S3 bucket for application assets
- A private RDS MySQL instance

## Repository Layout

```text
modules/
  Reusable Terraform modules shared by live infrastructure stacks.

live/dev/bootstrap-backend/
  Creates the S3 bucket and DynamoDB table used by Terraform state for dev.

live/dev/webapp/
  Deploys the application foundation for the dev environment.

docs/
  Placeholder for architecture notes, runbooks, and operational guidance.
```

## Deployment Workflow

1. Apply `live/dev/bootstrap-backend` to create remote-state resources.
2. Copy the generated bucket and lock-table values into `live/dev/webapp/backend.hcl`.
3. Choose or adapt a variable file from `live/dev/webapp/tfvars/`.
4. Run `terraform init -backend-config=backend.hcl`, then `terraform plan` and `terraform apply` with the selected `-var-file`.
5. Validate the deployed website and infrastructure outputs.

## Backend Bootstrap

`live/dev/bootstrap-backend` exists because Terraform cannot use an S3 backend until the backend bucket already exists.

Expected backend config after bootstrapping:

```hcl
bucket         = "your-generated-state-bucket"
key            = "environments/dev/webapp/terraform.tfstate"
region         = "ap-southeast-1"
profile        = "default"
encrypt        = true
dynamodb_table = "your-lock-table"
```

## Configuration Notes

- The checked-in defaults are intentionally neutral and should be treated as a baseline, not as production policy.
- `live/dev/webapp/backend.hcl.example` should be copied to `backend.hcl` and filled with real backend resources before `terraform init`.
- `live/dev/webapp/tfvars/dev.tfvars` is the current starter configuration for the dev environment.
- `live/dev/webapp/tfvars/prod.tfvars.example` documents a more production-oriented baseline with separate CIDRs, larger instance sizes, and Multi-AZ enabled.
- Resource naming is derived from `project_name` and `environment`, and provider-level default tags include repository, environment, stack, and component metadata.
- The current stack is cost-conscious rather than production-hardened: RDS uses single-AZ, backups are disabled, and some lifecycle protections are intentionally minimal.

## Usage

Bootstrap backend resources:

```bash
cd live/dev/bootstrap-backend
terraform init
terraform fmt -recursive
terraform validate
terraform apply
```

Deploy the web application foundation:

```bash
cd live/dev/webapp
cp backend.hcl.example backend.hcl
terraform init -backend-config=backend.hcl
terraform fmt -recursive
terraform validate
terraform plan -var-file=tfvars/dev.tfvars
terraform apply -var-file=tfvars/dev.tfvars
```

To test a production-oriented input set without creating a dedicated prod stack yet:

```bash
terraform plan -var-file=tfvars/prod.tfvars.example
```

## Validation

Basic validation steps after deployment:

- `terraform output` to confirm the website URL, RDS endpoint, and S3 bucket name
- `curl "$(terraform output -raw website_url)"` to confirm the web page is reachable
- `terraform state list` to confirm the expected resources are under management
- AWS CLI checks for RDS status, S3 bucket settings, and security group rules

## Current Tradeoffs

This repository is being upgraded from a learning-oriented delivery into a reusable infrastructure project. The current code is functional, but still intentionally simple in a few areas:

- Single environment layout
- Backend settings copied manually between stacks
- No CI pipeline or lint/security scanning yet
- No ALB, autoscaling, NAT, or private application tier yet
- Limited operational documentation

## Next Professionalization Steps

- Add CI for `terraform fmt`, `validate`, linting, and security scanning
- Introduce environment-specific variable files and backend conventions
- Harden lifecycle controls for RDS and S3
- Add runbooks, architecture docs, and deployment automation
