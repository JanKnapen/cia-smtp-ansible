# 🧩 Ansible DNS + Mail Setup

This repository contains Ansible playbooks to configure:
- A **Postfix mail gateway**
- A **BIND9 master DNS server**
- A **BIND9 slave DNS server**

It uses environment variables (`.env`) to safely store configuration details like your IP addresses and domain name.

## ⚙️ Setup

1. Copy the example environment file:
```bash
cp example.env .env
```
2. Edit `.env` and fill in your real values:
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
./run.sh [yourdomain.com] stage_id
```
🧩 Optional domain override

By default, the script reads the domain from `.env`.
You can override it by passing the domain name directly as the first argument — this is useful when testing or deploying multiple domains with the same infrastructure.

Examples:
```bash
# Use domain from .env
./run.sh stage2

# Override domain manually
./run.sh yourdomain.com stage3
```
In the second example, `yourdomain.com` temporarily overrides the `DOMAIN` value in `.env` for that run only.

6. Verify DNS setup (DNS propagation usually takes between 15–60 minutes):
```bash
$ dig NS yourdomain.com
;; ANSWER SECTION:
yourdomain.com.		3529	IN	NS	ns2.yourdomain.com.
yourdomain.com.		3529	IN	NS	ns1.yourdomain.com.
$ dig ns1.yourdomain.com
;; ANSWER SECTION:
ns1.yourdomain.com.	3330	IN	A	IP2
$ dig ns2.yourdomain.com
;; ANSWER SECTION:
ns2.yourdomain.com.     3330    IN      A       IP3
$ dig mail.yourdomain.com
;; ANSWER SECTION:
mail.yourdomain.com.	3456	IN	A	IP1
```

## 🧱 Stages

The setup process is divided into **several stages**, allowing you to deploy your infrastructure step-by-step:

### Stage 1 — Initial Setup (Baseline)
Run:
```bash
./run.sh stage1
```
This stage:
- Deploys all three servers (DNS master, DNS slave, and mail gateway)
- Configures DNS zones, mail routing, and hostnames

Use this stage while testing connectivity or before your mail server is ready to send authenticated emails.

---

### Stage 2 — SPF Enforcement
Run:
```bash
./run.sh stage2
```
This stage:
- Re-runs the same Ansible playbooks
- Enables SPF by adding the TXT record `v=spf1 ip4:IP1 -all to your DNS zone`
- Ensures Gmail and other mail providers can authenticate your domain

Use this stage once your mail server is properly configured and ready for real email delivery.

---

### Stage 3 — DKIM
Run:
```bash
./run.sh stage3
```
This stage:
- Keeps everything from Stage 2 (DNS + Mail + SPF)
- Enables DKIM signing on the mail server
  - Installs and configures OpenDKIM
  - Generates a unique RSA key pair for your domain (`default.private` and `default.txt`)
  - Integrates OpenDKIM with Postfix so all outgoing mail is cryptographically signed
- Publishes the DKIM public key automatically to your DNS master zone
  - The key appears in your zone as a TXT record at `default.\_domainkey.yourdomain.com`
  - The zone serial number updates automatically on each run
- Restarts both opendkim and postfix to apply the changes

Once deployed, your outgoing mail will include a DKIM-Signature header that Gmail, Outlook, and others can verify.

✅ You can test it by sending a message to your Gmail account and viewing Show original, where it should say:
```bash
DKIM: PASS (signature verified)
```

---

⚠️  Important: PTR (Reverse DNS) Record Required

To ensure your outgoing emails are accepted by major providers (like Gmail, Outlook, and Yahoo), your mail server’s IP must have a valid reverse DNS (PTR) record that matches its hostname.

Example:
```bash
IP1 → mail.yourdomain.com
mail.yourdomain.com → IP1
```

---

💡 Tip:

You can re-run each stage at any time. The playbooks are idempotent — they only apply changes when configuration differs.
