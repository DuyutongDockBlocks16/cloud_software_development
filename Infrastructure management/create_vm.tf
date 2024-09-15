# Configure the GCP provider

# export GOOGLE_APPLICATION_CREDENTIALS=/mnt/d/0x02_LearningAndWorking/Aalto/Cloud_software/learn-terraform-docker-container/credentials.json
# echo "$GOOGLE_APPLICATION_CREDENTIALS"
provider "google" {
  project = "css-ytd-2024"  # Replace with your GCP project ID
  region  = "europe-north1"         # Replace with your GCP region
  zone    = "europe-north1-a"           # Replace with your GCP zone
}

# Define input variable for VM name
variable "vm_name_input" {
  description = "The name of the VM instance"
  type        = string
}

# Create a custom VPC network
resource "google_compute_network" "custom_network" {
  name                    = "test-network"
  auto_create_subnetworks = false  # Custom subnetworks only
}

# Create a custom subnet in the VPC network
resource "google_compute_subnetwork" "custom_subnetwork" {
  name          = "custom-subnetwork"
  ip_cidr_range = "10.0.0.0/16"
  network       = google_compute_network.custom_network.id
  region        = "europe-north1" # Region for the subnet
}


# Create a firewall rule to allow HTTP traffic
resource "google_compute_firewall" "allow_http" {
  name    = "test-firewall"
  network = google_compute_network.custom_network.id

  allow  {
    protocol = "icmp"
  }

  allow  {
    protocol = "tcp"
    ports    = ["22", "80" , "8080"]
  }

#  allow  {
#    protocol = "tcp"
#    ports    = ["80"]
#  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["http-server","https-server"]
}

# Define a Compute Engine instance
resource "google_compute_instance" "vm_instance" {
  name         = var.vm_name_input   # Use input variable for VM name
  machine_type = "e2-medium"         # VM type

  tags = ["http-server","https-server"]

  labels = {
    course = "css-gcp"              # Add the required label
  }

  # Use Debian 11 image
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  # Network configuration
  network_interface {
    network    = google_compute_network.custom_network.id
    subnetwork = google_compute_subnetwork.custom_subnetwork.id

    access_config {
      # Ephemeral IP
    }
  }

  # Metadata startup script to install Apache2 and enable it
  metadata_startup_script = <<-EOT
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y apache2
    sudo systemctl start apache2
    sudo systemctl enable apache2
  EOT
}

# Output the VM name
output "vm_name" {
  description = "The name of the VM instance"
  value       = google_compute_instance.vm_instance.name
}

# Output the public IP address
output "public_ip" {
  description = "The public IP address of the VM"
  value       = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}
