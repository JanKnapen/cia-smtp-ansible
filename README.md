# 🧩 Ansible DNS + Mail Setup

This repository contains Ansible playbooks to configure:
- A **Postfix mail gateway**
- A **BIND9 master DNS server**
- A **BIND9 slave DNS server**

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
3. Ensure your servers are accessible via SSH and your user has sudo privileges.
4. Run the playbook:
```bash
./run.sh
```

