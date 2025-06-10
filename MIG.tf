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
