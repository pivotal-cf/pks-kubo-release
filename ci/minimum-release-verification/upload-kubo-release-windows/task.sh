#!/bin/bash

set -euxo pipefail

# define KUBO_WINDOWS_GIT_SHA as latest commit
source git-boshcycle-ci/ci/minimum-release-verification/utils/all-env.sh
setup_bosh_env

pushd git-pks-kubo-release-windows
  bosh create-release --version="${KUBO_WINDOWS_GIT_SHA}" --tarball pipeline.tgz
  bosh upload-release pipeline.tgz
popd
