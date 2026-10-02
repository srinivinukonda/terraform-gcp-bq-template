module "bigquery" {
  source = "../.."

  project_id  = "my-project"
  location    = "europe-west2"
  environment = "dev"
  labels      = { cost_centre = "data" }

  # kms_key_name = "projects/my-project/locations/europe-west2/keyRings/bq/cryptoKeys/bq"

  datasets = {
    bronze = {
      description = "Raw landing data"
      writers     = ["serviceAccount:etl@my-project.iam.gserviceaccount.com"]
      readers     = ["group:analysts@example.com"]
    }
  }
}
