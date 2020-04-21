#!/bin/bash

set -euxo pipefail

source git-kubo-odb-ci/scripts/lib/ci-helpers.sh
setup_bosh_env

pushd stemcell
  bosh upload-stemcell \
    --sha1 "$(cat sha1)" \
    "$(cat url)"?v="$(cat version)"
popd
