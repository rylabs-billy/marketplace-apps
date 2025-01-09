#!/bin/bash
# deployment_scripts/linode-marketplace-antmedia-community/test-vars.sh

# WARNING: Do not put TOKEN_PASSWORD in this file. Set it locallly for local
# testing, or provide it as a secret in GitHub Actions.

# NOTE: For local testing, manually set the $BRANCH and $GIT_REPO environment
# variables as needed.

source ./helpers/utils.sh

declare -A UDF_VARS
UDF_VARS["USER_NAME"]="testuser"
UDF_VARS["DISABLE_ROOT"]="Yes"
UDF_VARS["SUBDOMAIN"]="test"
UDF_VARS["DOMAIN"]="example.com" 
UDF_VARS["SOA_EMAIL_ADDRESS"]="test@example.com"

for key in "${!UDF_VARS[@]}"; do
  export $key="${UDF_VARS[$key]}"
  github:env "$key" "${UDF_VARS[$key]}"
done



# github_env() {
#   local KEY="$1"
#   local VALUE="$2"
#   if [ -n "$GITHUB_ENV" ]; then
#     echo "$KEY=$VALUE" | tee -a $GITHUB_ENV
#   fi
# }

# set_vars() {
#   for key in "${!UDF_VARS[@]}"; do
#     export "${key}"="${UDF_VARS[$key]}"
#     github_env "${key}" "${UDF_VARS[$key]}"
#   done
# }

# # main
# set_vars
