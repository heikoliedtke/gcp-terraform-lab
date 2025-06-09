output "load_balancer_ip" {
  description = "The public IP address of the HTTP Load Balancer."
  value       = google_compute_global_address.lb_static_ip.address
}

output "vpc_network_name" {
  description = "The name of the created VPC network."
  value       = google_compute_network.vpc_network.name
}

output "vpc_network_self_link" {
  description = "The self_link of the created VPC network."
  value       = google_compute_network.vpc_network.self_link
}

output "app_subnet_name" {
  description = "The name of the created subnet."
  value       = google_compute_subnetwork.app_subnet.name
}