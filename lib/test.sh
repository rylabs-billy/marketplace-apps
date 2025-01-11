#!/bin/bash
set -x

curl -ik https://localhost:14000/dir

REQUESTS_CA_BUNDLE="${ca_bundle}" certbot certonly --config "${config_file}" -vvv

# certbot -vvv -n --standalone --agree-tos --redirect certonly \
#   -d "${DOMAIN}" -d "${SUBDOMAIN}.${DOMAIN}" -m "${SOA_EMAIL_ADDRESS}"

echo sleeping....
echo
echo
sleep 10
echo done
exit 1
