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

# Firewall Rules
resource "google_compute_firewall" "delegate_fw" {
  name    = "${var.vm_name}-firewall"
  network = google_compute_network.delegate_vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "9079"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["harness", "delegate"]
}