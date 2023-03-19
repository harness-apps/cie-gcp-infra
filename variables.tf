variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "the region or zone where the cluster will be created"
  default     = "asia-south1"
}

variable "vm_name" {
  description = "The delegate vm name"
  default     = "harness-cie-delegate"
}

variable "vm_ssh_user" {
  description = "The SSH user for the vm"
  type        = string
}

# gcloud compute machine-types list
variable "machine_type" {
  description = "the google cloud machine types for each cluster node"
  # https://cloud.google.com/compute/docs/general-purpose-machines#n2_machine_types
  default = "n2-standard-4"
}

# gcloud compute images list
variable "machine_image" {
  description = "the base OS for the vm"
  default     = "debian-cloud/debian-11"
}

variable "harness_account_id" {
  description = "Harness Account Id to use while installing the delegate"
  type        = string
  sensitive   = true
}

variable "harness_delegate_token" {
  description = "Harness Delegate token"
  type        = string
  sensitive   = true
}

variable "harness_delegate_name" {
  description = "The Harness Delegate name"
  type        = string
  default     = "harness-delegate"
}

variable "harness_delegate_image" {
  description = "The Harness delegate image to use"
  type        = string
  default     = "harness/delegate:23.02.78500"
}

variable "harness_delegate_cpu" {
  description = "The number of cpus to set for the delegate docker runner"
  default     = "1.0"
  type        = string
}

variable "harness_delegate_memory" {
  description = "The memory to set for the delegate docker runner"
  default     = "2048m"
  type        = string
}

variable "drone_runner_image" {
  description = "The VM image to use for drone runner"
  type        = string
  default     = "projects/debian-cloud/global/images/debian-11-bullseye-v20230306"
}

variable "drone_runner_pool_count" {
  description = "The drone runner VM pool count"
  type        = number
  default     = 1
}

variable "drone_runner_pool_limit" {
  description = "The drone runner VM pool limit"
  type        = number
  default     = 1
}

variable "drone_runner_machine_type" {
  description = "The VM machine type to use for drone runners"
  # https://cloud.google.com/compute/docs/general-purpose-machines#e2_machine_types
  default = "e2-standard-4"
}


variable "drone_debug_enable" {
  description = "Enable Drone Debug Logs"
  type        = bool
  default     = false
}
variable "drone_trace_enable" {
  description = "Enable Drone Trace Logs"
  type        = bool
  default     = false
}
