#!/bin/bash
set -e

# Export variables from .env
set -a
source .env
set +a

# Handle the stage argument
STAGE=$1

if [ -z "$STAGE" ]; then
  echo "Usage: $0 <stage1|stage2|stage3>"
  exit 1
fi

case "$STAGE" in
  stage1)
    export ENABLE_SPF=false
    export ENABLE_DKIM=false
    ;;
  stage2)
    export ENABLE_SPF=true
    export ENABLE_DKIM=false
    ;;
  stage3)
    export ENABLE_SPF=true
    export ENABLE_DKIM=true
    ;;
  *)
    echo "Invalid stage: $STAGE"
    echo "Valid options: stage1, stage2, stage3"
    exit 1
    ;;
esac

echo "Running $STAGE (ENABLE_SPF=$ENABLE_SPF, ENABLE_DKIM=$ENABLE_DKIM)"
ansible-playbook -i inventory.yml playbook.yml

