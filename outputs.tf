output "region" {
  value       = var.region
  description = "GCloud Region"
}

output "project_id" {
  value       = var.project_id
  description = "GCloud Project ID"
}

output "zone" {
  value       = local.google_zone
  description = "VM Instance Zone"
}

output "delegate_vm_name" {
  value       = var.vm_name
  description = "The Harness Delegate Name"
}

output "vm_ssh_user" {
  value       = var.vm_ssh_user
  description = "The SSH username to login into VM"
}

output "vm_external_ip" {
  value       = google_compute_instance.delegate_vm.network_interface.0.access_config.0.nat_ip
  description = "The external IP to access the VM"
}