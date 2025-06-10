variable "project_id" {
  description = "The GCP project ID to deploy resources into."
  type        = string
}

variable "region" {
  description = "The GCP region for regional resources."
  type        = string
}

variable "network_name" {
  description = "The name for the VPC network."
  type        = string  
}

variable "subnet_name" {
  description = "The name for the subnet."
  type        = string

}

variable "subnet_ip_cidr_range" {
  description = "The IP address range for the subnet."
  type        = string  
}

variable "firewall_allow_http_https_name" {
  description = "Name for the firewall rule allowing HTTP/HTTPS traffic."
  type        = string  
}

variable "firewall_allow_ssh_name" {
  description = "Name for the firewall rule allowing SSH traffic."
  type        = string
  
}

variable "instance_template_name" {
  description = "Name for the instance template."
  type        = string
  }

variable "machine_type" {
  description = "Machine type for the instances in the MIG."
  type        = string
  
}

variable "mig_name" {
  description = "Name for the Managed Instance Group."
  type        = string
  
}

variable "mig_target_size" {
  description = "Target number of instances in the MIG."
  type        = number
  
}

variable "mig_max_instances" {
  description = "Maximum number of instances for MIG autoscaler"
  type = number
  
}

variable "cpu_target_utilization" {
  description = "Target CPU utiliuation"
  type = number
  
}

variable "router_name" {
  description = "Name for the Cloud Router"
  type = string
  
}

variable "nat_gateway_name" {
  description = "Name for the Nat Gateway"
  type = string
  
}

variable "http_health_check_name" {
  description = "Name for the HTTP health check."
  type        = string
  
}

variable "backend_service_name" {
  description = "Name for the backend service."
  type        = string
  
}

variable "url_map_name" {
  description = "Name for the URL map."
  type        = string
  
}

variable "target_http_proxy_name" {
  description = "Name for the target HTTP proxy."
  type        = string
  
}

variable "global_forwarding_rule_name" {
  description = "Name for the global forwarding rule."
  type        = string
  
}

variable "static_ip_name" {
  description = "Name for the static IP address for the load balancer."
  type        = string
  
}

variable "instance_image" {
  description = "The image to use for the instances, e.g., 'debian-cloud/debian-12'."
  type        = string
  
}

variable "database_name" {
  description = "name of the database"
  type = string
  
}

variable "backend_bucket" {
  description = "the name of the GCS bucket for the state"
  type = string
  
}

