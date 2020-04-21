#!/bin/bash

set -euxo pipefail

source git-boshcycle-ci/ci/minimum-release-verification/utils/all-env.sh
setup_bosh_env

#####################
# Delete Deployment #
#####################
bosh delete-deployment \
  --non-interactive \
  --deployment="${DEPLOYMENT_NAME}"

###################
# Delete Releases #
###################
bosh delete-release \
  --non-interactive \
  kubo/"${LINUX_GIT_SHA}" \
  || true
bosh delete-release \
  --non-interactive \
  kubo-windows/"${WINDOWS_GIT_SHA}" \
  || true
