#!/bin/bash
set -e

# Usage:
#   ./run.sh -s stage_id [-d domain] [-ms mailserver_ip]
# Examples:
#   ./run.sh -s 1
#   ./run.sh -s 3 -d example.com
#   ./run.sh -s 4 -d example.com -ms 145.100.105.111

# --- Parse arguments ---
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 -s stage_id [-d domain] [-ms mailserver_ip]"
  exit 1
fi

STAGE=""
DOMAIN_FROM_ARG=""
MAILSERVER_FROM_ARG=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -s)
      STAGE="$2"
      shift 2
      ;;
    -d)
      DOMAIN_FROM_ARG="$2"
      shift 2
      ;;
    -ms)
      MAILSERVER_FROM_ARG="$2"
      shift 2
      ;;
    *)
      echo "❌ Unknown option: $1"
      echo "Usage: $0 -s stage_id [-d domain] [-ms mailserver_ip]"
      exit 1
      ;;
  esac
done

if [[ -z "$STAGE" ]]; then
  echo "❌ Missing required -s stage_id"
  echo "Usage: $0 -s stage_id [-d domain] [-ms mailserver_ip]"
  exit 1
fi

# --- Load .env file safely ---
if [[ ! -f .env ]]; then
  echo ".env file not found! Run 'cp example.env .env' first."
  exit 1
fi

set -o allexport
source <(grep -E '^[A-Za-z_][A-Za-z0-9_]*=' .env | sed 's/\r$//')
set +o allexport

# --- Override DOMAIN if passed ---
if [[ -n "$DOMAIN_FROM_ARG" ]]; then
  export DOMAIN="$DOMAIN_FROM_ARG"
  echo "🔄 Overriding domain from argument: DOMAIN=$DOMAIN"
else
  echo "📦 Using domain from .env: DOMAIN=$DOMAIN"
fi

# --- Override IP1 if passed ---
if [[ -n "$MAILSERVER_FROM_ARG" ]]; then
  export IP1="$MAILSERVER_FROM_ARG"
  echo "🔄 Overriding mailserver IP from argument: IP1=$IP1"
else
  echo "📦 Using mailserver IP from .env: IP1=$IP1"
fi

# --- Set up stage-based environment ---
case "$STAGE" in
  1)
    export ENABLE_SPF=false
    export ENABLE_DKIM=false
    export ENABLE_DMARC=false
    ;;
  2)
    export ENABLE_SPF=true
    export ENABLE_DKIM=false
    export ENABLE_DMARC=false
    ;;
  3)
    export ENABLE_SPF=true
    export ENABLE_DKIM=true
    export ENABLE_DMARC=false
    ;;
  4)
    export ENABLE_SPF=true
    export ENABLE_DKIM=true
    export ENABLE_DMARC=true
    ;;
  *)
    echo "❌ Unknown stage: $STAGE"
    echo "Usage: $0 -s {1|2|3|4} [-d domain] [-ms mailserver_ip]"
    exit 1
    ;;
esac

# --- Run ansible ---
echo "🚀 Running Ansible for $DOMAIN ($STAGE) with IP $IP1..."
ansible-playbook -i inventory.yml playbook.yml

