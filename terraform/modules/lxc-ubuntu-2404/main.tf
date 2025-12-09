resource "proxmox_lxc" "lxc-ubuntu-2404" {
  hostname     = var.hostname
  vmid         = var.vm_id != null ? var.vm_id : null
  description  = "**${var.servicename}**. \n\nIP: ${var.static_ip} \n\nGateway: ${var.gateway_ip}"

  target_node  = var.target_node
  pool         = var.target_pool
  unprivileged = var.unprivileged
  password     = var.root_password

  cores        = var.cpu_cores
  memory       = var.ram
  swap         = var.swap
  ostemplate   = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
  tags         = var.tags
  start        = true
  onboot       = var.onboot
  startup      = var.startup

  ssh_public_keys = <<-EOT
    ${var.root_public_key}
  EOT

  network {
    name   = "eth0"
    bridge = var.network_interface
    ip     = var.static_ip != "" ? "${var.static_ip}/24" : "dhcp"
    gw     = var.gateway_ip
  }

  # Boot disk
  rootfs {
    storage = var.target_storage
    size    = "${var.boot_disk_size}G"
  }

  features {
    nesting = true
  }

  # Wait to make sure that the host is started
  provisioner "local-exec" {
    command = "sleep 10"
  }

  # Connect to the remote host and execute some commands
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/${var.root_private_key_name}")
    host        = var.static_ip
    timeout     = "3m"
  }

  provisioner "remote-exec" {
    inline = [
      # Create ansible user
      "useradd --create-home -s /bin/bash -p $(openssl passwd -6 '${var.ansible_password}') ${var.ansible_username}",
      #"adduser --disabled-password --gecos '' ${var.ansible_username}",
      "mkdir -p /home/${var.ansible_username}/.ssh",

      "echo '${var.root_public_key}' > /home/${var.ansible_username}/.ssh/authorized_keys",
      "chown -R ${var.ansible_username}:${var.ansible_username} /home/${var.ansible_username}/.ssh",
      "chmod 700 /home/${var.ansible_username}/.ssh",
      "chmod 600 /home/${var.ansible_username}/.ssh/authorized_keys",

      # Add to sudo group and allow sudo without password (optional)
      "usermod -aG sudo ${var.ansible_username}",
      #"echo 'ansibleuser ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ansibleuser",
      #"chmod 440 /etc/sudoers.d/ansibleuser",

      "systemctl enable ssh",
      "systemctl start ssh",
    ]
  }
}