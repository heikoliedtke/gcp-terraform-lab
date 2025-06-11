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
    # access_config {
      // Ephemeral public IP, useful for initial setup like package downloads
      // Not strictly needed if you have a NAT gateway
    #}
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    gsutil cp -r gs://cloud-training/cepf/cepf020/flask_cloudsql_example_v1.zip .
    apt-get install zip unzip wget python3-venv -y
    unzip flask_cloudsql_example_v1.zip
    cd flask_cloudsql_example/sqlalchemy
    curl -o cloud-sql-proxy https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.15.2/cloud-sql-proxy.linux.amd64
    chmod +x cloud-sql-proxy
    export INSTANCE_HOST='127.0.0.1'
    export DB_PORT='5432'
    export DB_USER='postgres'
    export DB_PASS='postgres'
    export DB_NAME='cepf-db'
    CONNECTION_NAME=$(gcloud sql instances describe cepf-instance --format="value(connectionName)")
    nohup ./cloud-sql-proxy $${CONNECTION_NAME} &
    python3 -m venv env
    source env/bin/activate
    pip install -r requirements.txt
    sed -i 's/127.0.0.1/0.0.0.0/g' app.py
    sed -i 's/8080/80/g' app.py
    nohup python app.py &
  EOT
  tags = ["http-server", "allow-ssh"]

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
  depends_on = [ google_sql_database_instance.cepf_instance ]
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

resource "google_compute_region_autoscaler" "app_mig_autoscaler" {
  name = "${var.mig_name}-autoscaler"
  region = var.region
  target = google_compute_region_instance_group_manager.app_mig.id
  autoscaling_policy {
    min_replicas = var.mig_target_size
    max_replicas = var.mig_max_instances
    cooldown_period = 60
    cpu_utilization {
      target = var.cpu_target_utilization
    }
  }
}