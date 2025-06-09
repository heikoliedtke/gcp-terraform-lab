terraform {
  backend "gcs" {
    bucket  = "your-gcs-bucket-name" # Replace with your GCS bucket name
    prefix  = "path/to/your/terraform.tfstate"  # Optional: path within the bucket
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