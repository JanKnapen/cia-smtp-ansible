# Proxmox LXC container infra

Deploying the CIA containers infrastructure using Terraform.


## Preconfiguration

**For Terraform:**
- [ ] Make sure the target Proxmox Hypervisor has an `infra_as_code@pve` account with the right permissions to create LXC containers.
- [ ] Copy the `terraform/terraform.tfvars.example` file to `terraform/terraform.tfvars` and change the credentials.
- [ ] Make sure the following LXC container templates are downloaded and present (`local (pve)` > CT Templates > Templates):
    - `local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst`


Initialize Terraform
```bash
cd terraform/
terraform init
```


## Deploying hosts

```bash
terraform plan
terraform apply
```

A single host (for example if you modified anything)
```bash
terraform apply -target=module.lxc2404[\"cia-dns-main\"]
terraform apply -target=module.lxc2404[\"cia-dns-main\"]
```