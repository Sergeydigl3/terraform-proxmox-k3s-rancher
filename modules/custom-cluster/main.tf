terraform {
  required_providers {
    # https://registry.terraform.io/providers/Telmate/proxmox/latest/docs
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.14"
    }
  }
}

resource "proxmox_vm_qemu" "control-plane" {
  count = var.controller_count
  name  = "${var.preffix_vm}${var.cluster_name}-control-${count.index}"
  tags  = "${var.cluster_name},control"

  target_node = var.proxmox_node

  clone = var.template_name

  agent    = 1
  os_type  = "cloud-init"
  cores    = 2
  sockets  = 1
  cpu      = "host"
  memory   = 2048
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"

  disk {
    slot     = 0
    size     = "10G"
    type     = "scsi"
    storage  = "moredata"
    iothread = 0
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  lifecycle {
    ignore_changes = [
      network,
    ]
  }

  ipconfig0 = "ip=dhcp"

  nameserver = var.proxmox_dns

  sshkeys = file("${var.ssh_public_key_path}")

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${var.ssh_private_key_path}")
    host        = self.default_ipv4_address
  }

  provisioner "file" {
    destination = "/tmp/bootstrap_k3s.sh"
    content = templatefile("${path.module}/bootstrap_k3s.sh.tpl",
      {
        k3s_token           = var.k3s_token,
        k3s_cluster_join_ip = proxmox_vm_qemu.control-plane[0].default_ipv4_address
      }
    )
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "chmod +x /tmp/bootstrap_k3s.sh",
      "sudo /tmp/bootstrap_k3s.sh"
    ]
  }
}

resource "proxmox_vm_qemu" "worker" {
  count = var.workers_count
  name  = "${var.preffix_vm}${var.cluster_name}-worker-${count.index}"
  tags  = "${var.cluster_name},worker"

  depends_on = [
    proxmox_vm_qemu.control-plane[0]
  ]

  target_node = var.proxmox_node

  clone = var.template_name

  agent    = 1
  os_type  = "cloud-init"
  cores    = 2
  sockets  = 1
  cpu      = "host"
  memory   = 2048
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"

  disk {
    slot     = 0
    size     = "10G"
    type     = "scsi"
    storage  = "moredata"
    iothread = 0
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  lifecycle {
    ignore_changes = [
      network,
    ]
  }

  ipconfig0 = "ip=dhcp"

  nameserver = var.proxmox_dns

  sshkeys = file("${var.ssh_public_key_path}")

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${var.ssh_private_key_path}")
    host        = self.default_ipv4_address
  }

  provisioner "file" {
    destination = "/tmp/bootstrap_k3s.sh"
    content = templatefile("${path.module}/bootstrap_k3s.sh.tpl",
      {
        k3s_token = var.k3s_token,
        k3s_cluster_join_ip = proxmox_vm_qemu.control-plane[0].default_ipv4_address,
        k3s_cluster_name = var.cluster_name
      }
    )
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "chmod +x /tmp/bootstrap_k3s.sh",
      "sudo /tmp/bootstrap_k3s.sh"
    ]
  }
}

resource "null_resource" "get_config" {
  depends_on = [proxmox_vm_qemu.control-plane]

  provisioner "remote-exec" {
    inline = [
      "cat /etc/rancher/k3s/k3s.yaml > /tmp/k3s_config.yaml",
      "sed -i.bak \"s/127.0.0.1/${proxmox_vm_qemu.control-plane[0].default_ipv4_address}/\" /tmp/k3s_config.yaml",
      "sed -i '/clusters:/,/^  name: default/s/^  name: default/  name: ${var.cluster_name}/' /tmp/k3s_config.yaml",
      "sed -i '/contexts:/,/users:/s/cluster: default/cluster: ${var.cluster_name}/' /tmp/k3s_config.yaml",
      "kubectl config --kubeconfig=/tmp/k3s_config.yaml rename-context default ${var.cluster_name}",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
      host        = proxmox_vm_qemu.control-plane[0].default_ipv4_address
    }
  }

  provisioner "local-exec" {
    command = <<EOT
mkdir -p ${var.configs_output_local}
scp -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -i ${var.ssh_private_key_path} ubuntu@${proxmox_vm_qemu.control-plane[0].default_ipv4_address}:/tmp/k3s_config.yaml ${var.configs_output_local}/k3s_config_${var.cluster_name}.yaml
EOT
  }
}
