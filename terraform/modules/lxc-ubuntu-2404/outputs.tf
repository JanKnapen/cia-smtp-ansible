output "container_id" {
  description = "The ID of the created LXC container"
  value       = proxmox_lxc.lxc-ubuntu-2404.id
}

output "container_name" {
  description = "The hostname of the created LXC container"
  value       = proxmox_lxc.lxc-ubuntu-2404.hostname
}

output "container_ip" {
  description = "The IP address of the created LXC container"
  value       = one(proxmox_lxc.lxc-ubuntu-2404.network.*.ip)
}
