provider "google" {
  project = var.project_id
  region  = var.region
}

# VPC
resource "google_compute_network" "delegate_vpc" {
  name                    = "${var.vm_name}-vpc"
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "delegate_subnet" {
  name          = "${var.vm_name}-vpc-subnet"
  region        = var.region
  network       = google_compute_network.delegate_vpc.name
  ip_cidr_range = "10.10.0.0/24"
}

resource "google_compute_subnetwork" "delegate_runner_subnet" {
  name          = "${var.vm_name}-vpc-runner-subnet"
  region        = var.region
  network       = google_compute_network.delegate_vpc.name
  ip_cidr_range = "10.20.0.0/24"
}

# Firewall Rules
resource "google_compute_firewall" "delegate_builder_fw" {
  name    = "${var.vm_name}-vpc-allow-9079"
  network = google_compute_network.delegate_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["9079"]
  }

  source_tags = ["harness-delegate"]
  target_tags = ["runner"]
}

# resource "google_compute_firewall" "runner_docker" {
#   name    = "${var.vm_name}-vpc-allow-docker"
#   network = google_compute_network.delegate_vpc.name

#   allow {
#     protocol = "tcp"
#     ports    = ["2376"]
#   }

#   source_ranges = [google_compute_subnetwork.delegate_runner_subnet.ip_cidr_range,google_compute_subnetwork.delegate_runner_subnet.ip_cidr_range]
#   target_tags   = ["runner"]
# }

resource "google_compute_firewall" "delegate_ssh_fw" {
  name    = "${var.vm_name}-vpc-allow-ssh"
  network = google_compute_network.delegate_vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "9079"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["harness-delegate"]
}
