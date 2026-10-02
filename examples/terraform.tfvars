# Example application tfvars. The application repo holds only a file like this;
# the pipeline reads template_name/template_version/state_* and runs this template.
template_name    = "terraform-gcp-bq-template"
template_version = "v1.1.0"
state_bucket     = "my-project-tfstate"
state_prefix     = "infra/dev/bq"

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
