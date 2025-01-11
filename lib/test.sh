#!/bin/bash
set -x

certbot --config "${config_file}" -vvv

# certbot -vvv -n --standalone --agree-tos --redirect certonly \
#   -d "${DOMAIN}" -d "${SUBDOMAIN}.${DOMAIN}" -m "${SOA_EMAIL_ADDRESS}"

echo sleeping....
echo
echo
sleep 10
echo done
exit 1
