output "host_ids" {
  description = "The IDs of all created LXC containers"
  value       = { for k, m in module.lxc2404 : k => m.container_id }
}

output "host_hostnames" {
  description = "The hostnames of all created LXC containers"
  value       = { for k, m in module.lxc2404 : k => m.container_name }
}

output "host_ips" {
  description = "The IP addresses of all created LXC containers"
  value       = { for k, m in module.lxc2404 : k => m.container_ip }
}