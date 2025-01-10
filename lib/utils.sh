#!/bin/bash
# helpers/util.sh

# utility functions
set -x

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

  _err () {
    echo "Error: missing or incorrect value for \$${1} variable"
    exit 1
  }

  err_msg="missing value for $"
  for var in "${vars_list[@]}"; do
    [ -z "${var}" ] && _err "${var}"
  done
}