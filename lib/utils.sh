#!/bin/bash
# helpers/util.sh

# utility functions
github:path () {
  local path="$1"
  if [ -n "$GITHUB_PATH" ]; then
    echo "$path" >> $GITHUB_PATH
  fi
}

github:env () {
  local key="$1"
  local value="$2"
  if [ -n "$GITHUB_ENV" ]; then
    echo "$key=$value" | tee -a $GITHUB_ENV
  fi
}

install_go () {
  echo "[info] installing go"
  local version=1.23.4
  local platform="linux-amd64"
  local checksum="6924efde5de86fe277676e929dc9917d466efa02fb934197bc2eba35d5680971"
  local package="go$version.$platform.tar.gz"

  curl -sLO "https://go.dev/dl/${package}"
  echo "${checksum} ${package}" | sha256sum -c
  rm -rf /usr/local/go && tar -C /usr/local -xzf "${package}"
  export PATH="${PATH}:/usr/local/go/bin:${HOME}/go/bin"
  echo "export PATH=${PATH}:/usr/local/go/bin:${HOME}/go/bin" | tee -a "${HOME}/.bashrc"
  github:path "${PATH}"
}

var_chk () {
  echo "[info] checking variables"
  local vars_list=("$@")

  _ok () {
    printf "\u2705  ${1} variable is set\n" && return 0
  }

  _err () {
    printf "\u274c  ${1} variable is not set\n" && return 1
  }

  for var in "${vars_list[@]}"; do
    v=$(echo "${!var}")
    [ -n "${v}" ] && _ok "${var}" || _err "${var}"
  done
}

domain_gen () {
  _domain="${1}"
  test_domain=$(openssl rand -base64 10 | tr -dc 'A-Za-z' | tr [:upper:] [:lower:])
  test_domain+=".${_domain}"
  export TEST_DOMAIN="${test_domain}"
}
