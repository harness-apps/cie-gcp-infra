## Provision required artifacts on the Delegate VM
resource "null_resource" "provision_delegate_vm" {

  triggers = {
    config_update = var.update_runner_config
  }

  provisioner "file" {
    source      = "${path.module}/runner"
    destination = "/home/${var.vm_ssh_user}"
    connection {
      type        = "ssh"
      host        = google_compute_instance.delegate_vm.network_interface.0.access_config.0.nat_ip
      user        = var.vm_ssh_user
      private_key = local.vm_user_ssh_private_key
      agent       = "false"
    }
  }

  provisioner "file" {
    source      = "${path.module}/scripts/run.sh"
    destination = "/home/${var.vm_ssh_user}/run.sh"
    connection {
      type        = "ssh"
      host        = google_compute_instance.delegate_vm.network_interface.0.access_config.0.nat_ip
      user        = var.vm_ssh_user
      private_key = local.vm_user_ssh_private_key
      agent       = "false"
    }
  }
}

# Starts or Stops the delegate
resource "null_resource" "start_stop_delegate" {

  triggers = {
    action = var.stop_harness_delegate
    config_update = var.update_runner_config
  }
  
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/${var.vm_ssh_user}/run.sh",
      "/home/${var.vm_ssh_user}/run.sh ${var.stop_harness_delegate}",
    ]
    connection {
      type        = "ssh"
      host        = google_compute_instance.delegate_vm.network_interface.0.access_config.0.nat_ip
      user        = var.vm_ssh_user
      private_key = local.vm_user_ssh_private_key
      agent       = "false"
    }
  }
}
