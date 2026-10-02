# terraform-gcp-bq-template

Opinionated template for BigQuery datasets. Application repos consume it by version tag; it wraps the
base module [terraform-gcp-bigquery](https://github.com/srinivinukonda/terraform-gcp-bigquery) and enforces:

- **Labels**: `env`, `managed_by = terraform`, `template` and `template_version` on every dataset, plus any common/per-dataset labels.
- **IAM**: additive (`google_bigquery_dataset_iam_member`). `readers` / `writers` / `owners` map to
  `roles/bigquery.dataViewer` / `dataEditor` / `dataOwner`; `iam_members` adds any other role.
- **CMEK**: `kms_key_name` at template level, optionally overridden per dataset.
  *Currently optional (null = Google-managed) until KMS keys are available.*

## How it is used

This repo is a **root module**. Application repos don't contain Terraform code, only a
`terraform.tfvars` file (see [`examples/terraform.tfvars`](examples/terraform.tfvars)):

```hcl
template_name    = "terraform-gcp-bq-template"
template_version = "v1.1.0"
state_bucket     = "my-project-tfstate"
state_prefix     = "infra/dev/bq"

project_id  = "my-project"
location    = "europe-west2"
environment = "dev"

datasets = {
  bronze = {
    description = "Raw landing data"
    writers     = ["serviceAccount:etl@my-project.iam.gserviceaccount.com"]
    readers     = ["group:analysts@example.com"]
    iam_members = { "roles/bigquery.metadataViewer" = ["user:someone@example.com"] }
  }
}
```

The pipeline (GitHub Actions or Jenkins) then:

1. reads `template_name` and `template_version` from the tfvars,
2. clones this repo at that tag,
3. runs `terraform init -backend-config=bucket=<state_bucket> -backend-config=prefix=<state_prefix>`,
4. runs `terraform plan/apply -var-file=<application tfvars>`.

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_id` | string | — | Project that owns the datasets |
| `location` | string | — | Location for all datasets |
| `environment` | string | — | `dev`, `test`, `uat` or `prod` |
| `kms_key_name` | string | `null` | Default CMEK key |
| `labels` | map(string) | `{}` | Labels for every dataset |
| `datasets` | map(object) | `{}` | Datasets keyed by ID; see `variables.tf` |
| `template_name` | string | `terraform-gcp-bq-template` | Read by the pipeline; also a dataset label |
| `template_version` | string | `unknown` | Read by the pipeline; also a dataset label |
| `state_bucket` / `state_prefix` | string | `null` | Read by the pipeline for `-backend-config` |

## Outputs

`datasets`: map of dataset ID to `dataset_id`, `id`, `self_link`, `kms_key_name`, `iam_members`.

## Versioning

Released with semver git tags. Each release pins a specific base-module tag (currently `v1.0.0`).

- `v1.0.0`: child module (called with `module { source = ... }`).
- `v1.1.0`: root module run by the pipeline from application tfvars.
