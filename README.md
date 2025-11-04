# 🧩 Ansible DNS + Mail Setup

This repository contains Ansible playbooks to configure:
- A **Postfix mail gateway**
- A **BIND9 master DNS server**
- A **BIND9 slave DNS server**

It uses environment variables (.env) to safely store configuration details like your IP addresses and domain name.

## ⚙️ Setup

1. Copy the example environment file:
```bash
cp example.env .env
```
2. Edit .env and fill in your real values:
```bash
DOMAIN=yourdomain.com
IP1=1.2.3.4
IP2=1.2.3.5
IP3=1.2.3.6
ANSIBLE_USER=ubuntu
```
3. Point your domain to your DNS servers. In your **domain registrar’s DNS settings** (for example, TransIP, Namecheap, or GoDaddy), you need to set the nameservers for your domain to point to your two DNS servers.

| Name Server | Hostname | Example IP |
|--------------|-----------|------------|
| **ns1** | `ns1.yourdomain.com` | IP2 |
| **ns2** | `ns2.yourdomain.com` | IP3 |

4. Ensure your servers are accessible via SSH and your user has sudo privileges.
5. Run the playbook:
```bash
./run.sh
```
6. Verify DNS setup:
```bash
dig NS yourdomain.com
dig ns1.yourdomain.com
dig ns2.yourdomain.com
dig @IP2 yourdomain.com
dig @IP3 yourdomain.com
```
