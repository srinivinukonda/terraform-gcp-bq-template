variable "project_id" {
  description = "Project that owns the datasets."
  type        = string
}

variable "location" {
  description = "Location for all datasets, e.g. europe-west2."
  type        = string
}

variable "environment" {
  description = "Environment name, applied as the env label."
  type        = string

  validation {
    condition     = contains(["dev", "test", "uat", "prod"], var.environment)
    error_message = "environment must be one of dev, test, uat, prod."
  }
}

variable "kms_key_name" {
  description = "Default CMEK key for every dataset. Null means Google-managed encryption (temporary until CMEK is rolled out)."
  type        = string
  default     = null
}

variable "labels" {
  description = "Labels added to every dataset. The env and managed_by labels are always set by the template."
  type        = map(string)
  default     = {}
}

variable "datasets" {
  description = <<-EOT
    Datasets to create, keyed by dataset ID. Principals use the user:, group:,
    serviceAccount: or domain: prefix.
      readers     -> roles/bigquery.dataViewer
      writers     -> roles/bigquery.dataEditor
      owners      -> roles/bigquery.dataOwner
      iam_members -> any other role => principals
    kms_key_name overrides the template-level key for one dataset.
  EOT
  type = map(object({
    description                     = optional(string)
    friendly_name                   = optional(string)
    labels                          = optional(map(string), {})
    kms_key_name                    = optional(string)
    default_table_expiration_ms     = optional(number)
    default_partition_expiration_ms = optional(number)
    delete_contents_on_destroy      = optional(bool, false)
    readers                         = optional(list(string), [])
    writers                         = optional(list(string), [])
    owners                          = optional(list(string), [])
    iam_members                     = optional(map(list(string)), {})
  }))
  default = {}
}

# Pipeline metadata. The pipeline reads these from the application's terraform.tfvars
# to pick the template repo/tag and the state location; they are declared here so the
# same tfvars file can be passed to Terraform as-is.
variable "template_name" {
  description = "Template repository name (set by the application tfvars, used for labels)."
  type        = string
  default     = "terraform-gcp-bq-template"
}

variable "template_version" {
  description = "Template version tag, e.g. v1.1.0 (set by the application tfvars, used for labels)."
  type        = string
  default     = "unknown"
}

variable "state_bucket" {
  description = "GCS bucket for Terraform state. Read by the pipeline for -backend-config; unused by Terraform."
  type        = string
  default     = null
}

variable "state_prefix" {
  description = "GCS prefix for Terraform state. Read by the pipeline for -backend-config; unused by Terraform."
  type        = string
  default     = null
}
