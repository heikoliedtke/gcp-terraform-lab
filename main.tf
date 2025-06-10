provider "google" {
  project = var.project_id
  region  = var.region
}

# VPC Network
resource "google_compute_network" "vpc_network" {
  name                    = var.network_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# Subnet
resource "google_compute_subnetwork" "app_subnet" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_ip_cidr_range
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

# Firewall Rule: Allow HTTP/HTTPS traffic to tagged instances
resource "google_compute_firewall" "allow_http_https" {
  name    = var.firewall_allow_http_https_name
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"] # Allows traffic from any source
  target_tags   = ["http-server"]
}

# Firewall Rule: Allow SSH traffic to tagged instances
# WARNING: Allowing SSH from 0.0.0.0/0 is not recommended for production.
# Consider restricting source_ranges to your IP or using IAP.
resource "google_compute_firewall" "allow_ssh" {
  name    = var.firewall_allow_ssh_name
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-ssh"]
}
