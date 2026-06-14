ENV ?= dev
WEBAPP_DIR := live/$(ENV)/webapp
BOOTSTRAP_DIR := live/$(ENV)/bootstrap-backend
VAR_FILE ?= tfvars/$(ENV).tfvars
BACKEND_CONFIG ?= backend.hcl

.PHONY: fmt validate bootstrap-init bootstrap-plan bootstrap-apply webapp-init webapp-plan webapp-apply webapp-destroy smoke hooks-install hooks-run

fmt:
	terraform fmt -recursive

validate:
	terraform -chdir=$(BOOTSTRAP_DIR) validate
	terraform -chdir=$(WEBAPP_DIR) validate

bootstrap-init:
	terraform -chdir=$(BOOTSTRAP_DIR) init

bootstrap-plan:
	terraform -chdir=$(BOOTSTRAP_DIR) plan

bootstrap-apply:
	terraform -chdir=$(BOOTSTRAP_DIR) apply

webapp-init:
	terraform -chdir=$(WEBAPP_DIR) init -backend-config=$(BACKEND_CONFIG)

webapp-plan:
	terraform -chdir=$(WEBAPP_DIR) plan -var-file=$(VAR_FILE)

webapp-apply:
	terraform -chdir=$(WEBAPP_DIR) apply -var-file=$(VAR_FILE)

webapp-destroy:
	terraform -chdir=$(WEBAPP_DIR) destroy -var-file=$(VAR_FILE)

smoke:
	./scripts/smoke-check-webapp.sh $(WEBAPP_DIR)

hooks-install:
	pre-commit install

hooks-run:
	pre-commit run --all-files
