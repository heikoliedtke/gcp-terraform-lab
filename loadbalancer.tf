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

  #health_checks = [google_compute_health_check.http_health_check.id]
  
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