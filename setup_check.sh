#!/bin/bash

IP="$1"
DOMAIN="$2"

if [ -z "$IP" ] || [ -z "$DOMAIN" ]; then
  echo "Usage: $0 <ip> <domain>"
  exit 1
fi

echo "NS records:"
dig NS "$DOMAIN" +short

echo "ns1:"
dig "ns1.$DOMAIN" +short

echo "mail:"
dig "mail.$DOMAIN" +short

echo "PTR:"
dig -x "$IP" +short

