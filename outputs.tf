output "datasets" {
  description = "Created datasets, keyed by dataset ID."
  value = {
    for name, m in module.dataset : name => {
      dataset_id   = m.dataset_id
      id           = m.id
      self_link    = m.self_link
      kms_key_name = m.kms_key_name
      iam_members  = m.iam_members
    }
  }
}
