#!/bin/bash
# lib/certbot.sh

# testing setup for certbot helper
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

  REQUESTS_CA_BUNDLE="${CA_BUNDLE}" certbot certonly --config "${CONFIG_FILE}" \
    --debug-challenges --verbose --dry-run
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
}

certbot:config () {
  local server="https://localhost:14000/dir"
  local cli_ini=$(printf "%s\n" \
  "key-type = ecdsa" \
  "elliptic-curve = secp384r1" \
  "rsa-key-size = 4096" \
  "email = ${SOA_EMAIL_ADDRESS}" \
  "authenticator = standalone" \
  "agree-tos = true" \
  "server = ${server}" \
  "domains = ${DOMAIN},${SUBDOMAIN}.${DOMAIN}" \
  "redirect = true" \
  "non-interactive = true")

  export CONFIG_FILE="/etc/letsencrypt/deploy-cli.ini"
  github:env "CONFIG_FILE" "${CONFIG_FILE}"
  echo "${cli_ini}" | sed 's/- /  - /g' > "${CONFIG_FILE}"
}

# main
certbot:build
certbot:test
