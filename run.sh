#!/bin/bash
set -e

# Usage:
#   ./run.sh [domain] stage_id
# Examples:
#   ./run.sh stage1
#   ./run.sh yourdomain.com stage3

# --- Parse arguments ---
if [[ $# -eq 1 ]]; then
  DOMAIN_FROM_ARG=""
  STAGE="$1"
elif [[ $# -eq 2 ]]; then
  DOMAIN_FROM_ARG="$1"
  STAGE="$2"
else
  echo "Usage: $0 [domain] stage_id"
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

# --- Set up stage-based environment ---
case "$STAGE" in
  stage1)
    export ENABLE_SPF=false
    export ENABLE_DKIM=false
    export ENABLE_DMARC=false
    ;;
  stage2)
    export ENABLE_SPF=true
    export ENABLE_DKIM=false
    export ENABLE_DMARC=false
    ;;
  stage3)
    export ENABLE_SPF=true
    export ENABLE_DKIM=true
    export ENABLE_DMARC=false
    ;;
  stage4)
    export ENABLE_SPF=true
    export ENABLE_DKIM=true
    export ENABLE_DMARC=true
    ;;
  *)
    echo "❌ Unknown stage: $STAGE"
    echo "Usage: $0 [domain] {stage1|stage2|stage3|stage4}"
    exit 1
    ;;
esac

# --- Run ansible ---
echo "🚀 Running Ansible for $DOMAIN ($STAGE)..."
ansible-playbook -i inventory.yml playbook.yml

