terraform {
  backend "gcs" {
    bucket  = "qwiklabs-gcp-04-e54063a363ec-bucket-tfstate" # Replace with your GCS bucket name
  
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