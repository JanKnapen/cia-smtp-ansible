#!/bin/bash
set -e

# Usage:
#   ./run.sh -s stage_id [-d domain] [-ms mailserver_ip]
#   ./run.sh -s all
# Examples:
#   ./run.sh -s 1
#   ./run.sh -s 3 -d example.com
#   ./run.sh -s 4 -d example.com -ms 145.100.105.111
#   ./run.sh -s all

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



# --- Multi-stage (all) logic ---
if [[ "$STAGE" == "all" ]]; then
  echo "🚀 Running Ansible for all mailservers and DNS servers..."
  # Export all domains and IPs for multi-stage setup
  export ACTIVE_DOMAINS="${DOMAIN_1},${DOMAIN_2},${DOMAIN_3},${DOMAIN_4}"
  export ACTIVE_MAIL_IPS="${IP1_1},${IP1_2},${IP1_3},${IP1_4}"
  ansible-playbook -i inventory.yml playbook.yml
  exit 0
fi


# --- Single-stage logic (limit to one mail host) ---

case "$STAGE" in
  1|2|3|4)
    MAIL_HOST="ms$STAGE"
    # If -d or -ms are provided, override DOMAIN_n and IP1_n for this run
    if [[ -n "$DOMAIN_FROM_ARG" ]]; then
      export DOMAIN_$STAGE="$DOMAIN_FROM_ARG"
      echo "🔄 Overriding DOMAIN_$STAGE: $DOMAIN_FROM_ARG"
    fi
    if [[ -n "$MAILSERVER_FROM_ARG" ]]; then
      export IP1_$STAGE="$MAILSERVER_FROM_ARG"
      echo "🔄 Overriding IP1_$STAGE: $MAILSERVER_FROM_ARG"
    fi
    # Export only the active domain and mailserver IP for single-stage setup
    export ACTIVE_DOMAINS="$(eval echo \${DOMAIN_${STAGE}})"
    export ACTIVE_MAIL_IPS="$(eval echo \${IP1_${STAGE}})"
    echo "🚀 Running Ansible for $MAIL_HOST and DNS servers..."
    ansible-playbook -i inventory.yml playbook.yml --limit "$MAIL_HOST,dns_master,dns_slave"
    ;;
  *)
    echo "❌ Unknown stage: $STAGE"
    echo "Usage: $0 -s {1|2|3|4|all}"
    exit 1
    ;;
esac

