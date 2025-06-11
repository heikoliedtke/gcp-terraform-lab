# create terraform code for deployment of a Cloud SQL POSTGRES_14 instance.
resource "google_sql_database_instance" "cepf_instance" {
  name             = var.database_instance
  region           = var.region
  database_version = "POSTGRES_14"
  settings {
    tier = "db-f1-micro"
  }
  deletion_protection = false
}

resource "google_sql_database" "cepf_database" {
  name     = var.database_name
  instance = google_sql_database_instance.cepf_instance.name
  charset  = "UTF8"
  collation = "en_US.UTF8"
}

