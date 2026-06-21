# Architecture Overview

This document describes the infrastructure architecture deployed by `terraform-aws-webapp-foundation`.

## High-Level Diagram

```text
┌──────────────────────────────────────────────────────────────────────┐
│                          AWS Account                                 │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │                     VPC  (10.x.0.0/16)                        │  │
│  │                                                                │  │
│  │  ┌─────────────────────────────┐                               │  │
│  │  │    Public Subnet (AZ-a)     │                               │  │
│  │  │                             │                               │  │
│  │  │  ┌───────────────────────┐  │                               │  │
│  │  │  │   EC2 Web Server      │  │                               │  │
│  │  │  │   (t3.micro)          │  │                               │  │
│  │  │  │   HTTP :80            │  │                               │  │
│  │  │  └───────────────────────┘  │                               │  │
│  │  │                             │                               │  │
│  │  └──────────┬──────────────────┘                               │  │
│  │             │                                                  │  │
│  │  ┌──────────▼──────────────────────────────────────────────┐   │  │
│  │  │            Private DB Subnets                           │   │  │
│  │  │                                                         │   │  │
│  │  │  ┌────────────────────┐   ┌────────────────────┐        │   │  │
│  │  │  │  DB Subnet A       │   │  DB Subnet B       │        │   │  │
│  │  │  │  (AZ-a)            │   │  (AZ-b)            │        │   │  │
│  │  │  └────────────────────┘   └────────────────────┘        │   │  │
│  │  │                                                         │   │  │
│  │  │         ┌─────────────────────────┐                     │   │  │
│  │  │         │   RDS MySQL Instance    │                     │   │  │
│  │  │         │   (db.t3.micro)         │                     │   │  │
│  │  │         │   Port 3306             │                     │   │  │
│  │  │         └─────────────────────────┘                     │   │  │
│  │  │                                                         │   │  │
│  │  └─────────────────────────────────────────────────────────┘   │  │
│  │                                                                │  │
│  └────────────────────────────────────────────────────────────────┘  │
│                                                                      │
│  ┌────────────────────┐     ┌──────────────────────────────────┐     │
│  │  S3 Bucket         │     │  Terraform State Infrastructure  │     │
│  │  (Static Assets)   │     │  S3 Bucket + DynamoDB Lock Table │     │
│  └────────────────────┘     └──────────────────────────────────┘     │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

## Components

### Networking — `modules/vpc`

| Resource            | Purpose                                        |
| ------------------- | ---------------------------------------------- |
| VPC                 | Isolated network for all project resources      |
| Public Subnet       | Hosts the EC2 web server with internet access   |
| Private Subnet A    | First AZ for the RDS subnet group               |
| Private Subnet B    | Second AZ for the RDS subnet group              |
| Internet Gateway    | Provides internet access to the public subnet   |
| Route Table         | Routes public subnet traffic through the IGW    |

Dev uses `10.20.0.0/16`, prod uses `10.30.0.0/16` by default so the environments never overlap.

### Security — `modules/security_groups`

| Security Group | Inbound Rules            | Purpose                          |
| -------------- | ------------------------ | -------------------------------- |
| Web SG         | TCP 80 from `0.0.0.0/0` | Public HTTP access to EC2        |
| DB SG          | TCP 3306 from Web SG     | MySQL access from web tier only  |

### Compute — `modules/ec2`

- Amazon Linux 2023 AMI (latest, fetched dynamically)
- User data template renders a styled HTML landing page
- Page content (title, badge, headline, description) is configurable per environment

### Database — `modules/rds`

- MySQL 8.0 on RDS
- Placed in a DB subnet group spanning two AZs
- Dev: single-AZ, no backups, skip final snapshot, no deletion protection
- Prod: multi-AZ, 7-day backup retention, final snapshot, deletion protection on

### Storage — `modules/s3`

- Private S3 bucket with versioning enabled
- Lifecycle rules for noncurrent version expiration
- Dev: force-destroy enabled for easy teardown
- Prod: force-destroy disabled, longer retention

### Remote State — `live/*/bootstrap-backend`

- S3 bucket for Terraform state files
- DynamoDB table for state locking
- Provisioned separately so the backend exists before `terraform init`

## Environment Differences

| Setting                    | Dev                  | Prod                     |
| -------------------------- | -------------------- | ------------------------ |
| VPC CIDR                   | `10.20.0.0/16`       | `10.30.0.0/16`           |
| EC2 instance type          | `t3.micro`           | `t3.small`               |
| RDS instance class         | `db.t3.micro`        | `db.t3.small`            |
| RDS Multi-AZ               | No                   | Yes                      |
| RDS backup retention       | 0 days               | 7 days                   |
| RDS skip final snapshot    | Yes                  | No                       |
| RDS deletion protection    | No                   | Yes                      |
| S3 force destroy           | Yes                  | No                       |
| S3 noncurrent expiration   | 7 days               | 30 days                  |

## CI Pipeline

The repository uses GitHub Actions (`.github/workflows/terraform-checks.yml`) to run:

1. `terraform fmt -check` — formatting consistency
2. `terraform validate` — syntax and provider validation for all stacks
3. **TFLint** — Terraform best-practice linting with the AWS ruleset
4. **Checkov** — infrastructure-as-code security scanning
