terraform {
  required_version = ">= 1.6"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0, < 7.0"
    }
  }

  # Partial config: bucket and prefix are passed by the pipeline with -backend-config.
  backend "gcs" {}
}
