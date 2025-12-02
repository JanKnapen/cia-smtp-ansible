# 🧩 Ansible DNS + Mail Setup

This repository contains Ansible playbooks to configure:
- A **Postfix mail gateway**
- A **BIND9 master DNS server**
- A **BIND9 slave DNS server**

It uses environment variables (`.env`) to safely store configuration details like your IP addresses and domain name.

## ⚙️ VM Environment Setup

1. Copy the example environment file:
```bash
cp example.env .env
```
2. Edit `.env` and fill in your real values:
```bash
# For multi-stage/multi-mailserver setup:
DOMAIN_1=yourdomain1.com
DOMAIN_2=yourdomain2.com
DOMAIN_3=yourdomain3.com
DOMAIN_4=yourdomain4.com

IP1_1=1.2.3.4     # Mail server 1
IP1_2=1.2.3.5     # Mail server 2
IP1_3=1.2.3.6     # Mail server 3
IP1_4=1.2.3.7     # Mail server 4

# Shared DNS servers
IP2=1.2.3.8       # Master DNS
IP3=1.2.3.9       # Slave DNS

ANSIBLE_USER=ubuntu
```
3. Point your domain to your DNS servers. In your **domain registrar’s DNS settings** (for example, TransIP, Namecheap, or GoDaddy), you need to set the nameservers for your domain to point to your two DNS servers.

| Name Server | Hostname | Example IP |
|--------------|-----------|------------|
| **ns1** | `ns1.yourdomain.com` | IP2 |
| **ns2** | `ns2.yourdomain.com` | IP3 |

4. Ensure your servers are accessible via SSH and your user has sudo privileges.

5. Run the playbook for a single stage (as before):
```bash
./run.sh -s 2
./run.sh -s 3 -d yourdomain.com
./run.sh -s 4 -d yourdomain.com -ms 192.168.102.145
```
In these examples, the provided flags temporarily override `.env` values for that run only.

## ⚙️ PTR Records Setup
The following steps will work for your student server if PTR records are delegated to your publicly accessible server. We will then install bind9 on the hypervisor to host our own PTR records for domains connected to the VMs.

```bash
apt-get update
apt-get install bind9
```

In `/etc/bind/named.conf.local`:
```conf
zone "78.56.34.12.in-addr.arpa" {
    type master;
    file "/etc/bind/db.12.34.56.78.rev";
};
```

And then in `/etc/bind/db.12.34.56.78.rev`:
```conf
$TTL 86400
@   IN SOA hostname.studlab.master.nl. hostmaster.hostname.studlab.master.nl. (
        2025110901 ; Serial
        3600       ; Refresh
        1800       ; Retry
        604800     ; Expire
        86400 )    ; Minimum TTL
    IN NS  hostname.studlab.master.nl.
    IN PTR mail.testingdomainname.nl.
```

Then
```bash
named-checkconf
systemctl edit named.service

# Add new with the following two lines:
# [Service]
# Type=simple

systemctl daemon-reload
systemctl restart bind9
```

Now the PTR should be configured correctly.


### 🚀 Multi-stage/multi-mailserver setup

To set up all four mailservers (ms1–ms4) with their respective domains and stages in one go, use:
```bash
./run.sh -s all
```
This will:
- Set up stage 1 on mailserver 1 with domain 1
- Set up stage 2 on mailserver 2 with domain 2
- Set up stage 3 on mailserver 3 with domain 3
- Set up stage 4 on mailserver 4 with domain 4
All using the same two DNS servers (IP2 and IP3) for each run.

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
./run.sh -s 1
```
This stage:
- Deploys all three servers (DNS master, DNS slave, and mail gateway)
- Configures DNS zones, mail routing, and hostnames

Use this stage while testing connectivity or before your mail server is ready to send authenticated emails.

---

### Stage 2 — SPF Enforcement
Run:
```bash
./run.sh -s 2
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
./run.sh -s 3
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

## Stage 4 — DMARC Enforcement
Run:
```bash
./run.sh -s 4
```
This stage:
- Keeps everything from Stage 3 (DNS + Mail + SPF + DKIM)
- Adds a DMARC record to your DNS zone for full email authentication enforcement
- Configures a TXT record under `_dmarc.yourdomain.com` with policy `p=quarantine` and reporting addresses
- Reloads BIND on the master DNS server and forces a retransfer to the slave, ensuring both servers publish the new record

After this stage, receivers such as Gmail and Outlook can enforce your DMARC policy.
Messages that fail SPF and DKIM alignment will be quarantined, and DMARC aggregate and forensic reports will be sent to your specified reporting mailboxes (dmarc-report@yourdomain.com).

✅ Verification

After running Stage 4, confirm that the record is visible publicly:
```bash
dig TXT _dmarc.yourdomain.com +short
```

You should see the DMARC policy string.

To check that mail authentication passes end-to-end, send a message to a Gmail account and click Show original — it should include `DMARC: PASS`.

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
