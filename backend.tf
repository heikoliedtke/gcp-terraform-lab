terraform {
  backend "gcs" {
    bucket  = var.backend_bucket # Replace with your GCS bucket name
  
  }
  required_providers {
    google = {
      source = "hashicorp/google"
      # You can pin the provider version here if needed, e.g., version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}