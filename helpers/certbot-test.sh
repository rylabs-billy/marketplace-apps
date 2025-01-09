#!/bin/bash

# setup test environment for certbot helper

readonly workflowDir=$(pwd)
readonly helperDir="/tmp/certbot"
readonly version=1.23.4
readonly platform="linux-amd64"
readonly checksum="6924efde5de86fe277676e929dc9917d466efa02fb934197bc2eba35d5680971"
readonly goArchive="go$version.$platform.tar.gz"
readonly testIP=127.0.0.201
readonly serverAddress="https://localhost:14000/dir"

source ./helpers/utils.sh

install_go () {
  curl -sLO "https://go.dev/dl/${goArchive}"
  echo "${checksum} ${goArchive}" | sha256sum -c
  rm -rf /usr/local/go && tar -C /usr/local -xzf ${goArchive}
  export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
  echo "export PATH=${PATH}:/usr/local/go/bin:${HOME}/go/bin" | tee -a "${HOME}/.bashrc"
  github:path "${PATH}"
}

run_pebble () {
    mkdir -p "${helperDir}" && cd "${helperDir}"
    git clone https://github.com/letsencrypt/pebble/
    cd pebble
    go install ./cmd/pebble

    sed -ie 's/"httpPort"\: .*/"httpPort"\: 80,/g' test/config/pebble-config.json
    sed -ie 's/"tlsPort"\: .*/"tlsPort"\: 443,/g' test/config/pebble-config.json
    cat test/config/pebble-config.json

    pebble_ca=$(realpath test/certs/pebble.minica.pem)
    export pebble_ca_path="${pebble_ca}"
    github:env "pebble_ca_path" "${pebble_ca}"

    # run pebble as a background process
    pebble -config test/config/pebble-config.json > /dev/null 2>&1 &
}

test_cerbot () {
  echo "${testIP} ${DOMAIN} ${SUBDOMAIN}.${DOMAIN}" | tee -a /etc/hosts
  apt install python3-certbot -y
  REQUESTS_CA_BUNDLE="${CA_BUNDLE}" certbot -n --standalone --agree-tos \
    --redirect certonly -d "${DOMAIN}" -d "${SUBDOMAIN}.${DOMAIN}" -m "${SOA_EMAIL}" \
    --server "${serverAddress}" --debug-challenges --verbose --dry-run
}

certbot_alias () {
  echo >> "${HOME}/.bashrc"
  echo "# certbot" >> "${HOME}/.bashrc"
  cat <<EOF > "${HOME}/.bashrc"
certbot() {
  args="$@"
  REQUESTS_CA_BUNDLE="${CA_BUNDLE}" $(which certbot) "${args}" \
    --server https://localhost:14000/dir
}
EOF
}

# main
install_go
run_pebble
test_cerbot
certbot_alias
