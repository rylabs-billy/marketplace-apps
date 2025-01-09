#!/bin/bash


# reusable utility functions
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

set_vars() {
  local vars_dict="$1"
  for key in "${!vars_dict[@]}"; do
    export $key="${vars_dict[$key]}"
    github:env "$key" "${vars_dict[$key]}"
  done
}