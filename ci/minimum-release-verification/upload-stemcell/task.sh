#!/bin/bash

set -euxo pipefail

# set relevant BOSH env vars
source git-boshcycle-ci/ci/minimum-release-verification/utils/all-env.sh
setup_bosh_env

pushd stemcell
  bosh upload-stemcell \
    --sha1 "$(cat sha1)" \
    "$(cat url)"?v="$(cat version)"
popd
