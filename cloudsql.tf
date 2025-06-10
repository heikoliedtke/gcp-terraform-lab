# create terraform code for deployment of a Cloud SQL POSTGRES_14 instance.
resource "google_sql_database_instance" "main" {
  name             = var.database_name
  region           = var.region
  database_version = "POSTGRES_14"
  settings {
    tier = "db-f1-micro"
  }
  deletion_protection = false
}


