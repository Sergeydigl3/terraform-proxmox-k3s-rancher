module "custom_cluster_dev" {
  source = "./modules/custom-cluster"

  cluster_name     = "dev"
  controller_count = 1
  workers_count    = 1

  proxmox_node         = var.proxmox_node
  template_name        = var.template_name
  proxmox_dns          = var.proxmox_dns
  ssh_public_key_path  = var.ssh_public_key_path
  ssh_private_key_path = var.ssh_private_key_path
  k3s_token            = var.k3s_token
  configs_output_local = var.configs_output_local
  preffix_vm           = var.preffix_vm
}

output "dev_control_plane" {
  value = module.custom_cluster_dev
}

module "custom_cluster_prod" {
  source = "./modules/custom-cluster"

  cluster_name     = "prod"
  controller_count = 1
  workers_count    = 1

  proxmox_node         = var.proxmox_node
  template_name        = var.template_name
  proxmox_dns          = var.proxmox_dns
  ssh_public_key_path  = var.ssh_public_key_path
  ssh_private_key_path = var.ssh_private_key_path
  k3s_token            = var.k3s_token
  configs_output_local = var.configs_output_local
  preffix_vm           = var.preffix_vm
}

output "dev_workers" {
  value = module.custom_cluster_prod
}
