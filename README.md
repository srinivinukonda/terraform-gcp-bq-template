# terraform-gcp-bq-template

Opinionated template for BigQuery datasets. Application repos consume it by version tag; it wraps the
base module [terraform-gcp-bigquery](https://github.com/srinivinukonda/terraform-gcp-bigquery) and enforces:

- **Labels**: `env` and `managed_by = terraform` on every dataset, plus any common/per-dataset labels.
- **IAM**: additive (`google_bigquery_dataset_iam_member`). `readers` / `writers` / `owners` map to
  `roles/bigquery.dataViewer` / `dataEditor` / `dataOwner`; `iam_members` adds any other role.
- **CMEK**: `kms_key_name` at template level, optionally overridden per dataset.
  *Currently optional (null = Google-managed) until KMS keys are available.*

## Usage

```hcl
module "bigquery" {
  source = "git::https://github.com/srinivinukonda/terraform-gcp-bq-template.git?ref=v1.0.0"

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
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_id` | string | — | Project that owns the datasets |
| `location` | string | — | Location for all datasets |
| `environment` | string | — | `dev`, `test`, `uat` or `prod` |
| `kms_key_name` | string | `null` | Default CMEK key |
| `labels` | map(string) | `{}` | Labels for every dataset |
| `datasets` | map(object) | `{}` | Datasets keyed by ID; see `variables.tf` |

## Outputs

`datasets`: map of dataset ID to `dataset_id`, `id`, `self_link`, `kms_key_name`, `iam_members`.

## Versioning

Released with semver git tags. Each release pins a specific base-module tag (currently `v1.0.0`).
