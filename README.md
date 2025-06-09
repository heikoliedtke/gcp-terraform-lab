# GCP Infrastructure Deployment with Terraform

This Terraform configuration deploys a scalable web application environment on Google Cloud Platform (GCP). It sets up a custom Virtual Private Cloud (VPC), a subnet, firewall rules, a Regional Managed Instance Group (MIG) with a startup script to serve a basic web page, and a Global HTTP Load Balancer to distribute traffic to the instances.

## Architecture Overview

The following GCP resources will be created:

1.  **VPC Network (`google_compute_network`):** A custom VPC network to provide an isolated environment for your resources.
2.  **Subnet (`google_compute_subnetwork`):** A regional subnet within the VPC where the instances will reside.
3.  **Firewall Rules (`google_compute_firewall`):**
    *   Allows incoming HTTP (port 80) and HTTPS (port 443) traffic from any source to instances tagged `http-server`.
    *   Allows incoming SSH (port 22) traffic from any source to instances tagged `allow-ssh`. *Note: For production, restrict SSH source ranges.*
4.  **Instance Template (`google_compute_instance_template`):** Defines the configuration for instances in the MIG, including machine type, boot disk image, network interface, and a startup script.
5.  **Startup Script (`startup-script.sh`):** A shell script executed on each instance upon boot. This example script installs Apache and serves a simple "Hello World" page.
6.  **Regional Managed Instance Group (`google_compute_region_instance_group_manager`):** Manages a group of identical instances based on the instance template, providing auto-scaling, auto-healing, and rolling update capabilities.
7.  **HTTP Health Check (`google_compute_health_check`):** Used by the MIG for auto-healing and by the Load Balancer to determine instance health.
8.  **Global Static IP Address (`google_compute_global_address`):** A reserved external IP address for the Load Balancer.
9.  **Backend Service (`google_compute_backend_service`):** Defines how the Load Balancer distributes traffic to the MIG.
10. **URL Map (`google_compute_url_map`):** Directs incoming requests to the appropriate backend service (in this case, all traffic goes to the default backend).
11. **Target HTTP Proxy (`google_compute_target_http_proxy`):** Routes requests received by the Load Balancer to a URL map.
12. **Global Forwarding Rule (`google_compute_global_forwarding_rule`):** Forwards traffic from the Load Balancer's external IP address and port to the target HTTP proxy.

## Prerequisites

1.  **Terraform Installed:** Download and install Terraform from terraform.io.
2.  **Google Cloud SDK (gcloud) Installed and Authenticated:**
    *   Install `gcloud`: Google Cloud SDK Documentation
    *   Authenticate and set your project:
        ```bash
        gcloud auth application-default login
        gcloud config set project YOUR_PROJECT_ID
        ```
3.  **APIs Enabled:** Ensure the Compute Engine API is enabled in your GCP project:
    ```bash
    gcloud services enable compute.googleapis.com --project YOUR_PROJECT_ID
    ```
4.  **GCS Bucket for Terraform State:**
    *   Create a Google Cloud Storage bucket to store the Terraform state file remotely. This is configured in `main.tf` within the `terraform backend "gcs"` block.
    *   Ensure the identity running Terraform has `Storage Object Admin` (or equivalent) permissions on this bucket.

## Setup and Deployment

1.  **Clone the Repository (if applicable) or Create Files:**
    Ensure you have all the `.tf` files (`main.tf`, `variables.tf`, `outputs.tf`) and the `startup-script.sh` in your working directory.

2.  **Configure Variables:**
    *   Create a `terraform.tfvars` file in the root of the project directory.
    *   **At a minimum, set your GCP `project_id`:**
        ```terraform
        // terraform.tfvars
        project_id = "your-gcp-project-id-here"
        ```
    *   You can override other default variables defined in `variables.tf` by adding them to `terraform.tfvars`. For example:
        ```terraform
        // terraform.tfvars
        project_id = "your-gcp-project-id-here"
        region     = "europe-west1"
        ```

3.  **Update Backend Configuration:**
    Open `main.tf` and update the `terraform backend "gcs"` block with your GCS bucket name and desired prefix:
    ```terraform
    terraform {
      backend "gcs" {
        bucket  = "your-terraform-state-bucket-name" # <-- UPDATE THIS
        prefix  = "my-app/global-lb/terraform.tfstate"      # <-- UPDATE THIS (optional, but recommended)
      }
      // ...
    }
    ```

4.  **Initialize Terraform:**
    Navigate to the directory containing your Terraform files and run:
    ```bash
    terraform init
    ```
    This will download the necessary provider plugins and configure the backend. If you had a local state file previously, Terraform will ask if you want to migrate it to the GCS backend.

5.  **Review the Plan:**
    See what resources Terraform will create/modify:
    ```bash
    terraform plan
    ```

6.  **Apply the Configuration:**
    Deploy the resources to GCP:
    ```bash
    terraform apply
    ```
    Terraform will show you the plan again and ask for confirmation. Type `yes` to proceed.

7.  **Accessing the Application:**
    Once `terraform apply` is complete, the public IP address of the load balancer will be displayed as an output (`load_balancer_ip`). You can access this IP in your web browser to see the "Hello World" page.

## Cleaning Up

To remove all resources created by this Terraform configuration, run:
```bash
terraform destroy
.
├── main.tf                 # Core infrastructure definitions
├── variables.tf            # Input variable definitions
├── outputs.tf              # Output variable definitions (e.g., LB IP)
├── startup-script.sh       # Script run on instance startup
├── terraform.tfvars        # (You create this) Variable values for your deployment
└── README.md               # This file

This README provides a good overview for anyone looking to understand and use your Terraform setup. You can adjust the details as needed, especially the "Update Backend Configuration" section if you decide to pre-fill the bucket name or provide more specific instructions.
# gcp-terraform-lab
a terraform lab for provisioning GCP resources
