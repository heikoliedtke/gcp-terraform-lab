
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

# Cloud Router
resource "google_compute_router" "router" {
  name    = var.router_name
  region  = var.region
  network = google_compute_network.vpc_network.id
}

# Cloud NAT Gateway
resource "google_compute_router_nat" "nat_gateway" {
  name                               = var.nat_gateway_name
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

