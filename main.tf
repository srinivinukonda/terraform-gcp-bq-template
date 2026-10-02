locals {
  standard_labels = {
    env        = var.environment
    managed_by = "terraform"
    # Label values allow only lowercase letters, digits, - and _.
    template         = substr(replace(lower(var.template_name), "/[^a-z0-9_-]/", "-"), 0, 63)
    template_version = substr(replace(lower(var.template_version), "/[^a-z0-9_-]/", "-"), 0, 63)
  }

  # Standard reader/writer/owner groups merged with any extra role grants,
  # with empty roles dropped.
  dataset_iam = {
    for name, ds in var.datasets : name => {
      for role, members in {
        for role in distinct(concat(
          ["roles/bigquery.dataViewer", "roles/bigquery.dataEditor", "roles/bigquery.dataOwner"],
          keys(ds.iam_members),
          )) : role => distinct(concat(
          role == "roles/bigquery.dataViewer" ? ds.readers : [],
          role == "roles/bigquery.dataEditor" ? ds.writers : [],
          role == "roles/bigquery.dataOwner" ? ds.owners : [],
          lookup(ds.iam_members, role, []),
        ))
      } : role => members if length(members) > 0
    }
  }
}

module "dataset" {
  source   = "git::https://github.com/srinivinukonda/terraform-gcp-bigquery.git?ref=v1.0.0"
  for_each = var.datasets

  project_id                      = var.project_id
  dataset_id                      = each.key
  location                        = var.location
  friendly_name                   = each.value.friendly_name
  description                     = each.value.description
  labels                          = merge(var.labels, each.value.labels, local.standard_labels)
  kms_key_name                    = each.value.kms_key_name != null ? each.value.kms_key_name : var.kms_key_name
  default_table_expiration_ms     = each.value.default_table_expiration_ms
  default_partition_expiration_ms = each.value.default_partition_expiration_ms
  delete_contents_on_destroy      = each.value.delete_contents_on_destroy
  iam_members                     = local.dataset_iam[each.key]
}
