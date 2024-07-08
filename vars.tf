variable "proxmox_node" {
  description = "The Proxmox node where the VM will be created"
  type        = string
}

variable "template_name" {
  description = "The template name used for cloning VMs"
  type        = string
}

variable "proxmox_dns" {
  description = "The DNS server for the Proxmox VMs"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key"
  type        = string
}

variable "k3s_token" {
  description = "The token used for joining k3s cluster"
  type        = string
  default     = "myk3stoken"
}

variable "pm_api_url" {
  description = "Proxmox api url"
  type        = string
  sensitive   = true
}

variable "pm_api_token_id" {
  description = "Proxmox api token id"
  type        = string
  sensitive   = true
}

variable "pm_api_token_secret" {
  description = "Proxmox api token secret"
  type        = string
  sensitive   = true
}

variable "configs_output_local" {
  description = "The output config folder"
  default     = "output_configs"
  type        = string
}

variable "preffix_vm" {
  description = "Prefix for vm names"
  default     = "k3s-"
  type        = string
}
