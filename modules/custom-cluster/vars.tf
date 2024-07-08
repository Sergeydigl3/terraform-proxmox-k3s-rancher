variable "ssh_public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "proxmox_node" {
    default = "pve"
}

variable "proxmox_dns" {
    default = "192.168.1.1"
}

variable "template_name" {
    default = "ubuntu-2004-cloudinit-template"
}

variable "ssh_private_key_path" {
    default   = "~/.ssh/id_rsa"
    sensitive = true
}

variable "k3s_token" {
  default = "myk3stoken"
}

variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
}

# variable "configs_output_local_file" {
#   description = "The output config file"
#   type        = string
# }

variable "configs_output_local" {
  description = "The output config folder"
  default = "ouput_configs"
  type        = string
}

variable "preffix_vm" {
  description = "Prefix for vm names"
  default     = "k3s-"
  type        = string
}

variable "controller_count" {
  description = "Count of Control-Plane k3s"
  default     = 1
  type        = number
}

variable "workers_count" {
  description = "Count of workers k3s"
  default     = 1
  type        = number
}