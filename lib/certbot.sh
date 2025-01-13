#!/bin/bash
# lib/certbot.sh

# testing setup for certbot helper
set -x
readonly workdir=$(pwd)
source ./lib/utils.sh

certbot:pebble () {
  echo "[info] setting up pebble"
  mkdir -p /tmp/certbot && cd /tmp/certbot
  git clone https://github.com/letsencrypt/pebble/
  cd pebble
  go install ./cmd/pebble

  sed -ie 's/"httpPort"\: .*/"httpPort"\: 80,/g' test/config/pebble-config.json
  sed -ie 's/"tlsPort"\: .*/"tlsPort"\: 443,/g' test/config/pebble-config.json
  cat test/config/pebble-config.json

  export CA_BUNDLE=$(realpath test/certs/pebble.minica.pem)
  github:env "CA_BUNDLE" "${CA_BUNDLE}"

  # run pebble as a background process
  pebble -config test/config/pebble-config.json > /dev/null 2>&1 &
  cd "${workdir}"
}

certbot:test () {
  echo "[info] testing mock certbot"
  var_chk "CA_BUNDLE" "CONFIG_FILE"
  # local ca_bundle="${1}"
  # local test_ip=127.0.0.201

  # apt install python3-certbot -y
  # echo "${test_ip} ${DOMAIN} ${SUBDOMAIN}.${DOMAIN}" | tee -a /etc/hosts

  REQUESTS_CA_BUNDLE="${CA_BUNDLE}" certbot certonly --config "${CONFIG_FILE}" \
    --debug-challenges --verbose --dry-run

  # REQUESTS_CA_BUNDLE="${ca_bundle}" $(which certbot) -n --standalone --agree-tos \
  #   --redirect certonly -d "${DOMAIN}" -d "${SUBDOMAIN}.${DOMAIN}" -m "${SOA_EMAIL_ADDRESS}" \
  #   --server "${server}" --debug-challenges --verbose --dry-run
}

certbot:build () {
  echo "[info] build mock certbot"
  local test_ip=127.0.0.201

  var_chk "DOMAIN" "SUBDOMAIN" "SOA_EMAIL_ADDRESS"
  apt install python3-certbot -y
  echo "${test_ip} ${DOMAIN} ${SUBDOMAIN}.${DOMAIN}" | tee -a /etc/hosts
  
  install_go
  certbot:pebble
  certbot:config
  # var_chk "ca_bundle"
  # certbot:test #"${ca_bundle}"
}

certbot:config () {
  local server="https://localhost:14000/dir"
  local cli_ini=$(printf "%s\n" \
  "key-type = ecdsa" \
  "elliptic-curve = secp384r1" \
  "authenticator = standalone" \
  "domains = ${DOMAIN},${SUBDOMAIN}.${DOMAIN}" \
  "server = ${server}" \
  "non-interactive = True" \
  "email = ${SOA_EMAIL_ADDRESS}" \
  "agree-tos = True" \
  "redirect = True" \
  "max-log-backups = 0")

  export CONFIG_FILE="/etc/letsencrypt/deploy-cli.ini"
  github:env "CONFIG_FILE" "${CONFIG_FILE}"
  echo "${cli_ini}" | sed 's/- /  - /g' > "${CONFIG_FILE}"
}


# certbot() {
#   args="$@"
#   var_chk "pebble_ca"
#   certbot_cmd="REQUESTS_CA_BUNDLE=${pebble_ca} $(which certbot) ${args} "
#   certbot_cmd+="--server https://localhost:14000/dir"
#   eval "${certbot_cmd}"
# }

# main
certbot:build
certbot:test


