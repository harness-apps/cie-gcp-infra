provider "google" {
  project = var.project_id
  region  = var.region
}

# VPC which will be used by the Delegate and Builder VMs
resource "google_compute_network" "delegate_vpc" {
  name                    = "${var.vm_name}-vpc"
  auto_create_subnetworks = false
}

# Subnet used to allocate ips for all Delegate VMS
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

# Subnet used to allocate IP for all builder VMs
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


# Router 
resource "google_compute_router" "builde_router" {
  name    = "builder-nat-router"
  region  = google_compute_subnetwork.delegate_builder_subnet.region
  network = google_compute_network.delegate_vpc.id
}

# Builder Cloud NAT allowing internet access from builder VMS
resource "google_compute_router_nat" "nat" {
  name                               = "my-router-nat"
  router                             = google_compute_router.builde_router.name
  region                             = google_compute_router.builde_router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

#####################################################
## Firewall Rules
#####################################################

# Allow lite engine port 9079 from builder VMS
resource "google_compute_firewall" "delegate_builder_fw" {
  name    = "allow-docker-lite-engine"
  network = google_compute_network.delegate_vpc.name

  priority = 65534

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["9079"]
  }

  source_tags = ["harness-delegate"]
  target_tags = ["builder"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Allow all egress from Delegate VPC
resource "google_compute_firewall" "delegate_vpc_allow_egress" {
  name    = "allow-all-egress"
  network = google_compute_network.delegate_vpc.name

  priority = 65535

  direction = "EGRESS"

  allow {
    protocol = "all"
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Deny all ingress to Delegate VPC
resource "google_compute_firewall" "delegate_vpc_deny_ingress" {
  name    = "deny-all-ingress"
  network = google_compute_network.delegate_vpc.name

  priority = 65535

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "all"
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Allow SSH and 9079 to Delegate VM
# TODO use IAP Proxy
resource "google_compute_firewall" "delegate_fw" {
  name     = "allow-ssh-9079"
  network  = google_compute_network.delegate_vpc.name
  priority = 65534
  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "9079"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["harness-delegate", "builder"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}
