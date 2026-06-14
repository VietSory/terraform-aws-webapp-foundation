#!/usr/bin/env bash
set -euo pipefail

STACK_DIR="${1:-.}"

if ! command -v terraform >/dev/null 2>&1; then
  echo "terraform CLI is required but was not found in PATH." >&2
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required but was not found in PATH." >&2
  exit 1
fi

if [ ! -d "$STACK_DIR" ]; then
  echo "Stack directory does not exist: $STACK_DIR" >&2
  exit 1
fi

cd "$STACK_DIR"

echo "Checking Terraform outputs..."
website_url="$(terraform output -raw website_url)"
static_assets_bucket="$(terraform output -raw static_assets_bucket)"
rds_endpoint="$(terraform output -raw rds_endpoint)"

if [ -z "$website_url" ] || [ -z "$static_assets_bucket" ] || [ -z "$rds_endpoint" ]; then
  echo "One or more expected Terraform outputs are empty." >&2
  exit 1
fi

echo "Checking managed resource state..."
terraform state list | grep -q "module.ec2.aws_instance.web"
terraform state list | grep -q "module.rds.aws_db_instance.mysql"
terraform state list | grep -q "module.s3.aws_s3_bucket.static_assets"
terraform state list | grep -q "module.vpc.aws_vpc.this"

echo "Checking HTTP endpoint: $website_url"
response="$(curl --fail --silent --show-error --max-time 10 "$website_url")"

if ! printf "%s" "$response" | grep -q "Terraform"; then
  echo "Website response did not contain the expected Terraform marker text." >&2
  exit 1
fi

echo "Smoke check passed."
echo "Website URL: $website_url"
echo "Static assets bucket: $static_assets_bucket"
echo "RDS endpoint: $rds_endpoint"
