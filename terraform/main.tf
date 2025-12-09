module "lxc2404" {
  source = "./modules/lxc-ubuntu-2404"
  for_each = var.lxcs2404
  providers = {
    proxmox = proxmox
  }

  proxmox_api_url          = var.proxmox_api_url
  proxmox_api_token_id     = var.proxmox_api_token_id
  proxmox_api_token_secret = var.proxmox_api_token_secret
  root_public_key          = var.root_public_key
  root_private_key_name    = var.root_private_key_name

  ansible_username         = var.ansible_username
  ansible_password         = var.ansible_password

  target_node              = each.value.target_node
  target_pool              = each.value.target_pool
  target_storage           = each.value.target_storage
  unprivileged             = each.value.unprivileged
  hostname                 = each.value.hostname
  vm_id                    = each.value.vm_id
  servicename              = each.value.servicename
  cpu_cores                = each.value.cpu_cores
  ram                      = each.value.ram
  swap                     = each.value.swap
  boot_disk_size           = each.value.boot_disk_size
  network_interface        = each.value.network_interface
  static_ip                = each.value.static_ip
  gateway_ip               = each.value.gateway_ip
  onboot                   = each.value.onboot
  startup                  = each.value.startup
  root_password            = each.value.root_password
}