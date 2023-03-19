provider "google" {
  project = var.project_id
  region  = var.region
}

# VPC
resource "google_compute_network" "delegate_vpc" {
  name                    = "${var.vm_name}-vpc"
  auto_create_subnetworks = false
}

# Subnet
resource "google_compute_subnetwork" "delegate_subnet" {
  name          = "${var.vm_name}-vpc-subnet"
  region        = var.region
  network       = google_compute_network.delegate_vpc.name
  ip_cidr_range = "10.10.0.0/24"

  log_config {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "delegate_builder_subnet" {
  name          = "${var.vm_name}-vpc-build-subnet"
  region        = var.region
  network       = google_compute_network.delegate_vpc.name
  ip_cidr_range = "10.20.0.0/24"

  log_config {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# Firewall Rules
resource "google_compute_firewall" "delegate_builder_fw" {
  name    = "allow-docker-lite-engine"
  network = google_compute_network.delegate_vpc.name

  priority = 900

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["9079", "2376"]
  }

  source_tags = ["harness-delegate"]
  target_tags = ["builder"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

}

resource "google_compute_firewall" "delegate_fw" {
  name     = "allow-ssh-9079"
  network  = google_compute_network.delegate_vpc.name
  priority = 1000
  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "9079"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["harness-delegate"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}
