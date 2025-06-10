variable "project_id" {
  description = "The GCP project ID to deploy resources into."
  type        = string
}

variable "region" {
  description = "The GCP region for regional resources."
  type        = string
  default     = "us-central1"
}

variable "network_name" {
  description = "The name for the VPC network."
  type        = string
  default     = "my-custom-vpc"
}

variable "subnet_name" {
  description = "The name for the subnet."
  type        = string
  default     = "my-custom-subnet"
}

variable "subnet_ip_cidr_range" {
  description = "The IP address range for the subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "firewall_allow_http_https_name" {
  description = "Name for the firewall rule allowing HTTP/HTTPS traffic."
  type        = string
  default     = "fw-allow-http-https"
}

variable "firewall_allow_ssh_name" {
  description = "Name for the firewall rule allowing SSH traffic."
  type        = string
  default     = "fw-allow-ssh"
}

variable "instance_template_name" {
  description = "Name for the instance template."
  type        = string
  default     = "app-instance-template"
}

variable "machine_type" {
  description = "Machine type for the instances in the MIG."
  type        = string
  default     = "e2-medium"
}

variable "mig_name" {
  description = "Name for the Managed Instance Group."
  type        = string
  default     = "app-regional-mig"
}

variable "mig_target_size" {
  description = "Target number of instances in the MIG."
  type        = number
  default     = 2
}

variable "http_health_check_name" {
  description = "Name for the HTTP health check."
  type        = string
  default     = "http-basic-health-check"
}

variable "backend_service_name" {
  description = "Name for the backend service."
  type        = string
  default     = "app-backend-service"
}

variable "url_map_name" {
  description = "Name for the URL map."
  type        = string
  default     = "web-lb-url-map"
}

variable "target_http_proxy_name" {
  description = "Name for the target HTTP proxy."
  type        = string
  default     = "http-lb-target-proxy"
}

variable "global_forwarding_rule_name" {
  description = "Name for the global forwarding rule."
  type        = string
  default     = "http-content-rule"
}

variable "static_ip_name" {
  description = "Name for the static IP address for the load balancer."
  type        = string
  default     = "lb-static-ipv4-address"
}

variable "instance_image" {
  description = "The image to use for the instances, e.g., 'debian-cloud/debian-11'."
  type        = string
  default     = "projects/debian-cloud/global/images/family/debian-11"
}

variable "database_name" {
  description = "name of the database"
  type = string
  default = "cepf-db"
}