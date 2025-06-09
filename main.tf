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

# Instance Template for Managed Instance Group
resource "google_compute_instance_template" "app_template" {
  name_prefix  = "${var.instance_template_name}-"
  machine_type = var.machine_type
  region       = var.region

  disk {
    source_image = var.instance_image
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork = google_compute_subnetwork.app_subnet.self_link
    access_config {
      // Ephemeral public IP, useful for initial setup like package downloads
      // Not strictly needed if you have a NAT gateway
    }
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  metadata_startup_script = file("${path.module}/startup-script.sh")
  tags                    = ["http-server", "allow-ssh"]

  service_account {
    # Uses the default compute engine service account
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }
  lifecycle {
    create_before_destroy = true
  }
}

# Regional Managed Instance Group
resource "google_compute_region_instance_group_manager" "app_mig" {
  name               = var.mig_name
  region             = var.region
  base_instance_name = "${var.mig_name}-instance"

  version {
    instance_template = google_compute_instance_template.app_template.id
  }

  target_size = var.mig_target_size

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.http_health_check.id
    initial_delay_sec = 300 # Adjust as needed for your startup script
  }
}

# Global Static IP Address for Load Balancer
resource "google_compute_global_address" "lb_static_ip" {
  name = var.static_ip_name
}

# HTTP Health Check for Load Balancer and MIG Autohealing
resource "google_compute_health_check" "http_health_check" {
  name                = var.http_health_check_name
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3 # Consider higher for production

  http_health_check {
    port         = 80
    request_path = "/"
  }
}

# Backend Service for Load Balancer
resource "google_compute_backend_service" "app_backend_service" {
  name                  = var.backend_service_name
  protocol              = "HTTP"
  port_name             = "http" # Must match named_port in MIG
  load_balancing_scheme = "EXTERNAL"
  timeout_sec           = 30

  backend {
    group           = google_compute_region_instance_group_manager.app_mig.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }

  health_checks = [google_compute_health_check.http_health_check.id]

  # Optional: Enable Cloud CDN
  # enable_cdn = true 

  # Optional: Configure session affinity
  # session_affinity = "CLIENT_IP"
}

# URL Map for Load Balancer
resource "google_compute_url_map" "lb_url_map" {
  name            = var.url_map_name
  default_service = google_compute_backend_service.app_backend_service.id
}

# Target HTTP Proxy for Load Balancer
resource "google_compute_target_http_proxy" "http_target_proxy" {
  name    = var.target_http_proxy_name
  url_map = google_compute_url_map.lb_url_map.id
}

# Global Forwarding Rule for Load Balancer
resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {
  name                  = var.global_forwarding_rule_name
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80" # For HTTP. Use "443" for HTTPS.
  target                = google_compute_target_http_proxy.http_target_proxy.id
  ip_address            = google_compute_global_address.lb_static_ip.address
}