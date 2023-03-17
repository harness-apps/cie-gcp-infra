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
  google_zone = random_shuffle.az.result[0]
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
      image = "debian-cloud/debian-11"
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

  # TODO: enable workload identity
  metadata = {
    ssh-keys = <<EOT
${var.vm_ssh_user}:${local.vm_user_ssh_pub_key}
EOT
  }

  metadata_startup_script = <<EOS
sudo apt-get update
sudo apt install netcat
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

## Runner artifacts
resource "local_file" "drone_runner_pool" {
  content = templatefile("${path.module}/templates/pool.tfpl", {
    runnerHome        = "/home/${var.vm_ssh_user}/runner"
    runnerPoolCount   = "${var.drone_runner_pool_count}"
    runnerProject     = "${var.project_id}"
    runnerVMImage     = "${var.drone_runner_image}"
    runnerMachineType = "${var.drone_runner_machine_type}"
    runnerZone        = "${local.runner_zone}"
    runnerNetwork     = "${google_compute_network.delegate_vpc.id}"
    runnerSubNetwork  = "${google_compute_subnetwork.delegate_runner_subnet.id}"
  })
  filename        = "${path.module}/runner/pool.yml"
  file_permission = "0700"
}

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
