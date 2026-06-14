# Codex Handoff

## Project

Repository: `terraform-aws-webapp-foundation`

Local path: `D:\Coding\terraform-aws-webapp-foundation`

Remote: `https://github.com/VietSory/terraform-aws-webapp-foundation.git`

Primary branch: `main`

Purpose: turn an AWS Terraform learning project into a reusable, professional infrastructure repository for web application foundations across `dev` and `prod`.

## Current State

The repository now has a professional Terraform layout:

- `modules/` contains reusable Terraform modules for VPC, security groups, EC2, RDS, and S3.
- `live/dev/bootstrap-backend` creates the dev remote-state S3 bucket and DynamoDB lock table.
- `live/dev/webapp` deploys the dev web application foundation.
- `live/prod/bootstrap-backend` creates the prod remote-state S3 bucket and DynamoDB lock table.
- `live/prod/webapp` deploys the prod web application foundation.
- `scripts/smoke-check-webapp.sh` validates a deployed webapp stack after `terraform apply`.
- `Makefile` provides common commands for Terraform init, plan, apply, destroy, smoke checks, and pre-commit hooks.
- `.pre-commit-config.yaml` defines hygiene hooks and a local Terraform format hook.

## Commit History So Far

Completed commits:

1. `bbb6a86` `chore: establish terraform repository hygiene`
2. `d65be54` `refactor: remove course-specific naming and account coupling`
3. `26e63a2` `refactor: move shared terraform modules to top-level modules directory`
4. `e3f06aa` `refactor: introduce live dev stack layout for terraform environments`
5. `9ce9528` `feat: add shared naming and tagging conventions for dev stacks`
6. `b4ac0d2` `refactor: externalize backend config into backend hcl examples`
7. `319ab16` `feat: add dev and prod tfvars examples for the webapp stack`
8. `6c4f697` `feat: scaffold prod live stack from the dev baseline`
9. `e96e09e` `feat: make rds lifecycle and backup controls configurable`
10. `23d71e8` `feat: make s3 destroy and retention controls configurable`
11. `2f5bf06` `feat: improve ec2 user data maintainability with templates`
12. `441121a` `feat: add terraform smoke check script for webapp stacks`
13. `fd504e0` `chore: add makefile for common terraform workflows`
14. Current commit: add pre-commit hooks and this Codex handoff documentation.

## What Was Done Recently

The last three contribution commits focused on developer workflow:

- Added `scripts/smoke-check-webapp.sh` to verify Terraform outputs, expected resources in state, and HTTP reachability.
- Added `Makefile` targets to simplify common workflows like `make webapp-plan ENV=dev`.
- Added pre-commit hook configuration and this handoff file so another Codex session can continue with context.

## Useful Commands

From the repository root:

```bash
make fmt
make validate ENV=dev
make bootstrap-init ENV=dev
make webapp-init ENV=dev
make webapp-plan ENV=dev
make webapp-apply ENV=dev
make smoke ENV=dev
make hooks-install
make hooks-run
```

For prod:

```bash
make bootstrap-init ENV=prod
make webapp-init ENV=prod
make webapp-plan ENV=prod
make smoke ENV=prod
```

## Known Environment Limitations

In the current local Codex environment, the `terraform` and `pre-commit` CLIs have not been available in `PATH`. Previous sessions could run `git diff --check`, but could not run `terraform fmt`, `terraform validate`, real Terraform plans, or pre-commit hooks.

Before making infrastructure-sensitive changes, install or expose Terraform in `PATH`, then run:

```bash
make fmt
make validate ENV=dev
make validate ENV=prod
make hooks-install
make hooks-run
```

If deployed infrastructure exists, also run:

```bash
make smoke ENV=dev
make smoke ENV=prod
```

## Current Work

The current scope is commit 14 of an 18-commit professionalization roadmap:

- Add pre-commit hooks.
- Add handoff documentation for the next Codex agent.
- Keep the repo clean and push to `origin/main`.

## Recommended Next Commits

Continue with these remaining commits:

15. `feat: add github actions workflow for terraform checks`
16. `feat: add tflint and checkov configuration`
17. `docs: add architecture and deployment runbook`
18. `docs: add contribution guide and repository templates`

## Notes For The Next Codex

Keep commits meaningful and capability-based. The user wants more GitHub contributions, but not empty commits. Each commit should add a real workflow, safety control, documentation asset, or infrastructure capability.

Avoid force-pushing, rewriting history, or deleting existing stack files. The repo is already public on GitHub and `main` is the working branch.

The author identity used so far is:

```text
vietsory <vietpno3@gmail.com>
```
