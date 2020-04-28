#!/bin/bash

set -euxo pipefail

source git-kubo-odb-ci/scripts/lib/ci-helpers.sh
setup_bosh_env

export LINUX_GIT_SHA=`cat git-pks-kubernetes-release/.git/ref`
export WINDOWS_GIT_SHA=`cat git-pks-kubernetes-windows-release/.git/ref`

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
