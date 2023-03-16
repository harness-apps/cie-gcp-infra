locals {
  vm_user_ssh_pub_key     = file("${path.module}/.keys/delegate_id_rsa.pub")
  vm_user_ssh_private_key = file("${path.module}/.keys/delegate_id_rsa")
}

# This is used to set local variable google_zone.
data "google_compute_zones" "available" {
  region = var.region
}

resource "random_shuffle" "az" {
  input        = data.google_compute_zones.available.names
  result_count = 1
}

locals {
  google_zone = random_shuffle.az.result[0]
}

resource "google_service_account" "delegate_sa" {
  account_id   = var.vm_name
  display_name = "The SA to run harness-delegate vm"
}

resource "google_compute_instance" "delegate_vm" {
  depends_on = [
    google_compute_network.delegate_vpc,
    google_compute_subnetwork.delegate_subnet
  ]

  name         = var.vm_name
  machine_type = var.machine_type
  zone         = local.google_zone

  tags = ["harness", "delegate"]

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
echo "Jai Guru"
sudo apt-get update
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
mkdir /runner
EOS

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.delegate_sa.email
    scopes = ["cloud-platform"]
  }
}

# provisioner "file" {
#   content = templatefile("${path.module}/templates/pool.tpfl", {
#     runnerPoolName    = ""
#     runnerPoolCount   = ""
#     runnerProject     = ""
#     delegateSAKey     = ""
#     runnerVMImage     = ""
#     runnerMachineType = ""
#     runnerZone        = ""
#   })
#   destination = "/runner/pool.yml"
#   connection {
#     type        = "ssh"
#     user        = "jon"
#     private_key = ${local.vm_user_ssh_private}
#     agent       = "false"
#   }
# }

# provisioner "file" {
#   content = templatefile("${path.module}/templates/docker-compose.tpfl", {
#     delegateCPU          = ""
#     delegateMemory       = ""
#     delegateImage        = ""
#     delegateSAKey        = ""
#     harnessAccountId     = ""
#     harnessDelegateToken = ""
#     harnessDelegateName  = ""
#   })
#   destination = "/runner/docker-compose.yml"
#   connection {
#     type        = "ssh"
#     user        = "jon"
#     private_key = ${local.vm_user_ssh_private}
#     agent       = "false"
#   }
# }
