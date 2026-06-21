# Contributing to terraform-aws-webapp-foundation

Thank you for your interest in contributing! This guide explains how to set up a local development environment, follow project conventions, and submit changes.

## Prerequisites

| Tool            | Minimum Version | Installation                                      |
| --------------- | --------------- | ------------------------------------------------- |
| Terraform       | 1.5.0           | https://developer.hashicorp.com/terraform/install  |
| AWS CLI         | 2.x             | https://docs.aws.amazon.com/cli/latest/userguide/  |
| Git             | 2.x             | https://git-scm.com/                               |
| pre-commit      | 3.x             | `pip install pre-commit`                           |
| TFLint          | latest          | https://github.com/terraform-linters/tflint        |
| checkov         | latest          | `pip install checkov`                              |

## Getting Started

```bash
# Clone the repository
git clone https://github.com/VietSory/terraform-aws-webapp-foundation.git
cd terraform-aws-webapp-foundation

# Install pre-commit hooks
make hooks-install

# Run formatting and validation
make fmt
make validate ENV=dev
make validate ENV=prod
```

## Repository Structure

```text
modules/          Reusable Terraform modules (vpc, ec2, rds, s3, security_groups)
live/dev/         Dev environment stacks (bootstrap-backend, webapp)
live/prod/        Prod environment stacks (bootstrap-backend, webapp)
scripts/          Automation and validation scripts
docs/             Architecture notes and runbooks
.github/          CI workflows and repository templates
```

## Development Workflow

1. **Create a feature branch** from `main`:
   ```bash
   git checkout -b feat/your-feature-name
   ```

2. **Make your changes** following the conventions below.

3. **Run local checks** before committing:
   ```bash
   make fmt
   make validate ENV=dev
   make validate ENV=prod
   make hooks-run
   ```

4. **Commit with a conventional message** (see below).

5. **Open a Pull Request** against `main`.

## Commit Message Convention

This project follows [Conventional Commits](https://www.conventionalcommits.org/):

```text
<type>: <short description>

[optional body]
```

| Type       | When to use                                      |
| ---------- | ------------------------------------------------ |
| `feat`     | New capability, module, or infrastructure feature |
| `fix`      | Bug fix or correction                            |
| `refactor` | Code restructuring without behavior change       |
| `docs`     | Documentation only                               |
| `chore`    | Maintenance, tooling, CI updates                 |
| `test`     | Adding or updating tests/validation              |

Examples:
- `feat: add cloudwatch alarms for ec2 health`
- `fix: correct subnet CIDR overlap in prod`
- `docs: update deployment runbook with ALB steps`
- `chore: upgrade terraform required version to 1.6`

## Terraform Conventions

- **Formatting**: Always run `terraform fmt -recursive` before committing. The CI pipeline enforces this.
- **Naming**: Use `snake_case` for all resource names, variables, and outputs.
- **Variables**: Every variable must have a `description` and `type`. Use sensible defaults where possible.
- **Outputs**: Every output must have a `description`.
- **Modules**: Place reusable modules in `modules/<name>/` with `main.tf`, `variables.tf`, and `outputs.tf`.
- **Live stacks**: Environment-specific configuration belongs in `live/<env>/<stack>/`.
- **Backend config**: Never commit real `backend.hcl` files. Use `.example` files as templates.
- **Tags**: Rely on provider-level `default_tags` for consistent tagging. Do not add per-resource tags unless necessary.

## Adding a New Module

1. Create `modules/<module_name>/` with:
   - `main.tf` — resource definitions
   - `variables.tf` — input variables with descriptions
   - `outputs.tf` — output values with descriptions

2. Reference the module from `live/<env>/webapp/main.tf`:
   ```hcl
   module "<module_name>" {
     source = "../../../modules/<module_name>"
     # ...
   }
   ```

3. Add any new variables to `live/<env>/webapp/variables.tf` and the corresponding `tfvars/` files.

4. Run `make fmt` and `make validate ENV=dev` to confirm.

## Adding a New Environment

1. Copy an existing environment directory:
   ```bash
   cp -r live/dev live/staging
   ```

2. Update `locals.tf` to reflect the new environment name.

3. Create environment-specific `tfvars/staging.tfvars` with appropriate CIDRs and sizing.

4. Update `.github/workflows/terraform-checks.yml` to include the new stacks in the validation matrix.

## CI Pipeline

Every push and pull request triggers the GitHub Actions workflow which runs:

1. **Format check** — `terraform fmt -recursive -check`
2. **Validate** — `terraform validate` on all stacks (dev and prod)
3. **TFLint** — Terraform linting with the AWS ruleset
4. **Checkov** — Security scanning with documented suppressions

All checks must pass before merging.

## Security Scanning

Checkov suppressions are documented in `.checkov.yml` with rationale for each skipped check. When adding new infrastructure:

- Run `checkov -d . --config-file .checkov.yml` locally
- If a new finding is a known tradeoff, add it to `.checkov.yml` with a comment explaining why
- If a finding is actionable, fix it before submitting your PR

## Code Review Guidelines

- Every PR should be reviewed by at least one maintainer
- Changes to `modules/` require extra attention since they affect all environments
- Changes to prod configuration (`live/prod/`) should be reviewed for cost and safety implications
- Documentation updates are welcome and encouraged

## Questions?

Open a GitHub issue or reach out to the maintainers.
