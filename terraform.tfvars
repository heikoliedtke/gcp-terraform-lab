# Example terraform.tfvars file

# General Configuration
project_id = "qwiklabs-gcp-03-394040c70825"
region     = "us-central1"

# Network Configuration
network_name  = "vpc01"
subnet_name ="subnet01"
subnet_ip_cidr_range = "10.10.0.0/24"
firewall_allow_http_https_name = "fw-allow-http-https"
firewall_allow_ssh_name = "firewall-allow-ssh"
router_name = "cr01"
nat_gateway_name = "natgw01"

# Compute Instance Configuration
instance_template_name = "app-instance-template"
machine_type = "e2-medium"
mig_name = "cepf-lb-http-group1-mig"
mig_target_size = 2
mig_max_instances = 4
cpu_target_utilization = 0.6
http_health_check_name = "http-basic-health-check"
backend_service_name = "cepf-lb-http-backend-default" # Backend Nam
url_map_name = "web-lb-url-map"
global_forwarding_rule_name = "cepf-lb-http" # Frontend Forwarding Rule Name
static_ip_name = "lb-static-ipv4-address"
target_http_proxy_name = "http-lb-target-proxy"
instance_image = "projects/debian-cloud/global/images/family/debian-12"
database_name = "cepf-db"
database_instance = "cepf-instance"
backend_bucket = "tbd"


