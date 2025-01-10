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

  pebble_ca=$(realpath test/certs/pebble.minica.pem)
  export pebble_ca="${pebble_ca}"
  github:env "pebble_ca" "${pebble_ca}"

  # run pebble as a background process
  pebble -config test/config/pebble-config.json > /dev/null 2>&1 &
  cd "${workdir}"
}

certbot:test () {
  echo "[info] testing mock certbot"
  local ca_bundle="${1}"
  local test_ip=127.0.0.201
  local server="https://localhost:14000/dir"

  echo "${test_ip} ${DOMAIN} ${SUBDOMAIN}.${DOMAIN}" | tee -a /etc/hosts
  apt install python3-certbot -y
  REQUESTS_CA_BUNDLE="${ca_bundle}" $(which certbot) -n --standalone --agree-tos \
    --redirect certonly -d "${DOMAIN}" -d "${SUBDOMAIN}.${DOMAIN}" -m "${SOA_EMAIL_ADDRESS}" \
    --server "${server}" --debug-challenges --verbose --dry-run
}

certbot:configure () {
  echo "[info] configuring mock certbot"
  var_chk "DOMAIN" "SUBDOMAIN" "SOA_EMAIL_ADDRESS"

  install_go
  certbot:pebble

  var_chk "pebble_ca"
  certbot:test "${pebble_ca}"
}

certbot() {
  args="$@"
  var_chk "pebble_ca"
  certbot_cmd="REQUESTS_CA_BUNDLE=${pebble_ca} $(which certbot) ${args} "
  certbot_cmd+="--server https://localhost:14000/dir"
  eval "${certbot_cmd}"
}

# main
certbot:configure
bashrc certbot 


