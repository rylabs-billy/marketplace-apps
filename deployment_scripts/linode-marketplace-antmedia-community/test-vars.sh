#!/bin/bash
# deployment_scripts/linode-marketplace-antmedia-community/test-vars.sh

# WARNING: Do not put TOKEN_PASSWORD in this file. Set it locallly for local
# testing, or provide it as a secret in GitHub Actions.

# NOTE: For local testing, manually set the $BRANCH and $GIT_REPO environment
# variables as needed.

source ./lib/utils.sh

domain_gen "linodemarketplace.xyz"
[ -n "${GITHUB_OUTPUT}" ] && echo "test-domain=${TEST_DOMAIN}" >> $GITHUB_OUTPUT

declare -A UDF_VARS
UDF_VARS["USER_NAME"]="testuser"
UDF_VARS["DISABLE_ROOT"]="Yes"
UDF_VARS["SUBDOMAIN"]="test"
UDF_VARS["DOMAIN"]="${TEST_DOMAIN}" 
UDF_VARS["SOA_EMAIL_ADDRESS"]="test@${test_domain}"

for key in "${!UDF_VARS[@]}"; do
  export $key="${UDF_VARS[$key]}"
  github:env "$key" "${UDF_VARS[$key]}"
done
