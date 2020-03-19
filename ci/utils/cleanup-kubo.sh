#!/bin/bash

set -euxo pipefail

source git-boshcycle-ci/ci/utils/use-bosh.sh
source git-boshcycle-ci/ci/utils/kubo-sha.sh

cleanupKubo() {
  local deployment = $1

  if [ -d "$1" ]
  then
    #####################
    # Delete Deployment #
    #####################
    bosh delete-deployment \
      --non-interactive \
      --deployment="${deployment}" \
      || true
  fi

  ###################
  # Delete Release  #
  ###################
  bosh delete-release \
    --non-interactive \
    kubo/"${KUBO_GIT_SHA}" \
    || true
}

