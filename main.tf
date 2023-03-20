locals {
  vm_user_ssh_pub_key     = file("${path.module}/.keys/delegate_id_rsa.pub")
  vm_user_ssh_private_key = file("${path.module}/.keys/delegate_id_rsa")
}

# This is used to set local variable google_zone.
data "google_compute_zones" "available" {
  region = var.region
}

resource "random_shuffle" "az" {
  input = data.google_compute_zones.available.names
}

locals {
  # zone where delegate will be provisioned
  google_zone = random_shuffle.az.result[0]
  # zone where builders will be provisioned
  runner_zone = random_shuffle.az.result[1]
}

resource "google_compute_instance" "delegate_vm" {
  depends_on = [
    google_compute_network.delegate_vpc,
    google_compute_subnetwork.delegate_subnet
  ]

  name         = var.vm_name
  machine_type = var.machine_type
  zone         = local.google_zone

  tags = ["harness-delegate"]

  boot_disk {
    initialize_params {
      image = var.harness_delegate_vm_image
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "SCSI"
  }

  network_interface {
    # use the VPC delegate subnet
    subnetwork = google_compute_subnetwork.delegate_subnet.name

    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = <<EOT
${var.vm_ssh_user}:${local.vm_user_ssh_pub_key}
EOT
  }

  metadata_startup_script = <<EOS
sudo apt-get update
sudo apt install net-tools
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
EOS

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email = google_service_account.delegate_sa.email
    # TODO trim down the scope to only what is needed
    scopes = ["cloud-platform"]
  }
}

#####################################################
## Runner Artifacts
#####################################################

## pool.yml
resource "local_file" "drone_builder_pool" {
  content = templatefile("${path.module}/templates/pool.tfpl", {
    home        = "/home/${var.vm_ssh_user}/runner"
    poolName    = "${var.drone_builder_pool_name}"
    poolCount   = "${var.drone_builder_pool_count}"
    poolLimit   = "${var.drone_builder_pool_limit}"
    project     = "${var.project_id}"
    vmImage     = "${var.drone_builder_image}"
    machineType = "${var.drone_builder_machine_type}"
    zone        = "${local.runner_zone}"
    network     = "${google_compute_network.delegate_vpc.id}"
    subNetwork  = "${google_compute_subnetwork.delegate_builder_subnet.id}"
  })
  filename        = "${path.module}/runner/pool.yml"
  file_permission = "0700"
}

## docker-compose.yml
resource "local_file" "delegate_runner" {
  content = templatefile("${path.module}/templates/docker-compose.tfpl", {
    runnerHome           = "/home/${var.vm_ssh_user}/runner"
    delegateCPU          = "${var.harness_delegate_cpu}"
    delegateMemory       = "${var.harness_delegate_memory}"
    delegateImage        = "${var.harness_delegate_image}"
    harnessAccountId     = "${var.harness_account_id}"
    harnessDelegateToken = "${var.harness_delegate_token}"
    harnessDelegateName  = "${var.harness_delegate_name}"
  })
  filename        = "${path.module}/runner/docker-compose.yml"
  file_permission = "0700"
}

## .env that will be used by the delegate/runner
resource "local_file" "delegate_env" {
  content = templatefile("${path.module}/templates/.env.tfpl", {
    droneDebugEnable = "${var.drone_debug_enable}"
    droneTraceEnable = "${var.drone_trace_enable}"
  })
  filename        = "${path.module}/runner/.env"
  file_permission = "0700"
}
