
locals {
  drone_runner_sa_roles = ["roles/compute.instanceAdmin", "roles/compute.imageUser", "roles/iam.serviceAccountUser"]
}

resource "google_service_account" "delegate_sa" {
  account_id   = var.vm_name
  display_name = "The SA to run harness-delegate vm"
}

resource "google_project_iam_custom_role" "compute_networks_custom_role" {
  role_id     = "droneRunnerSANetworkRole"
  title       = "Drone Runner SA Network Role"
  description = "The filtered permissions that a Droner Runner SA"
  permissions = ["compute.networks.updatePolicy", "compute.firewalls.create"]
}

resource "google_project_iam_binding" "drone_runner_sa_roles" {
  for_each = toset(local.drone_runner_sa_roles)
  project  = var.project_id
  role     = each.key
  members = [
    google_service_account.delegate_sa.member,
  ]
}

resource "google_project_iam_binding" "drone_runner_sa_network_roles" {
  project = var.project_id
  role    = google_project_iam_custom_role.compute_networks_custom_role.id
  members = [
    google_service_account.delegate_sa.member,
  ]
}

resource "google_service_account_key" "delegate_sa_key" {
  service_account_id = google_service_account.delegate_sa.name
}

resource "local_sensitive_file" "sa_key" {
  filename = "${path.module}/runner/sa.json"
  content  = base64decode(google_service_account_key.delegate_sa_key.private_key)
}
