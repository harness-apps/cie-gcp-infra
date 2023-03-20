variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "the region or zone where the cluster will be created."
  default     = "asia-south1"
}

variable "vm_name" {
  description = "The delegate vm name"
  default     = "harness-cie-delegate"
}

variable "vm_ssh_user" {
  description = "The SSH user for the VM. Defaults to the system user."
  type        = string
}

# gcloud compute machine-types list
variable "machine_type" {
  description = "the google cloud machine types for each cluster node."
  # https://cloud.google.com/compute/docs/general-purpose-machines#n2_machine_types
  default = "n2-standard-4"
}

variable "harness_account_id" {
  description = "Harness AccountID that will be used by the delegate."
  type        = string
  sensitive   = true
}

variable "harness_delegate_token" {
  description = "Harness Delegate token"
  type        = string
  sensitive   = true
}

variable "harness_delegate_name" {
  description = "The name to to register the delegate with your Harness Account."
  type        = string
  default     = "gce-delegate"
}

variable "harness_delegate_vm_image" {
  description = "The VM image to use for the delegate compute instance."
  type        = string
  default     = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20230302"
}

variable "harness_delegate_image" {
  description = "The Harness delegate image to use"
  type        = string
  default     = "harness/delegate:23.02.78500"
}

variable "harness_delegate_cpu" {
  description = "The number of cpus to set for the delegate docker runner."
  default     = "1.0"
  type        = string
}

variable "harness_delegate_memory" {
  description = "The memory to set for the delegate docker runner."
  default     = "2048m"
  type        = string
}

variable "stop_harness_delegate" {
  description = "Stop the Harness Delegate Running inside the VM."
  default     = "false"
  type        = string
}

variable "drone_builder_image" {
  description = "The VM image to use for Drone builder VM."
  type        = string
  default     = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20230302"
}

variable "drone_builder_pool_name" {
  description = "The builder pool name. This pool name used in the Harness infrastructure as VM Pool Name."
  type        = string
  default     = "ubuntu-jammy"
}

variable "drone_builder_pool_count" {
  description = "The drone runner VM pool count"
  type        = number
  default     = 1
}

variable "drone_builder_pool_limit" {
  description = "The drone runner VM pool limit"
  type        = number
  default     = 1
}

variable "drone_builder_machine_type" {
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

variable "update_runner_config" {
  description = "Update the runner configuration file and restart the delegate"
  type        = string
  default     = "no"
}
