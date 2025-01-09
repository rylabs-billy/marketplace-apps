#!/bin/bash
# helpers/util.sh

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
