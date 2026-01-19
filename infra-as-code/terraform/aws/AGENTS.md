# Repository Guidelines

## Project Structure & Module Organization
- Root Terraform configuration lives in `main.tf`, `variables.tf`, `providers.tf`, and `outputs.tf`.
- `remote-state/` contains the bootstrap Terraform to create the S3/DynamoDB backend for state locking.
- `input.yaml` and `kafka-pdb.yaml` are supporting manifests; keep them alongside infra changes that require them.
- `.terraform/` and `state.json` are generated artifacts; do not hand-edit.
- Modules are referenced via `../modules/...` (e.g., network, db, storage); keep module interfaces stable when editing.

## Build, Test, and Development Commands
- `terraform init`: initialize providers and the S3 backend in this directory.
- `terraform plan -var='db_password=...'`: preview infra changes; required because `db_password` has no default.
- `terraform apply -var='db_password=...'`: apply the planned changes.
- `terraform fmt -recursive`: format all Terraform files consistently.
- `terraform validate`: basic configuration validation.
- In `remote-state/`, run `terraform init/plan/apply` first to provision the backend resources.

## Coding Style & Naming Conventions
- Use 2-space indentation and standard HCL formatting (`terraform fmt`).
- Prefer `snake_case` for variables and outputs; keep resource labels descriptive and consistent with existing patterns (e.g., `es-master`, `es-data-v1`).
- Provide `description` fields for new variables and outputs when the purpose is not obvious.

## Testing Guidelines
- No automated test suite is defined; rely on `terraform validate` and a clean `terraform plan`.
- For changes that affect EKS, RDS, or security groups, verify the plan carefully and note expected impact in the PR.

## Commit & Pull Request Guidelines
- History favors short, imperative summaries like `Update ...` or `Fix ...`; follow that style.
- PRs should include a clear description, list of modules/areas touched, and a sanitized `terraform plan` summary.
- Link relevant issues and call out any production-impacting changes explicitly.

## Security & Configuration Tips
- Do not commit secrets; pass `db_password` at runtime.
- Treat `kubeconfig_bmc-prod` and `state.json` as sensitive and avoid sharing them.
- Never edit Terraform state files manually; use the backend workflow instead.
