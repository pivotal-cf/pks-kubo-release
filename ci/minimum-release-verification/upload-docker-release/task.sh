#!/bin/bash

set -euxo pipefail

source git-boshcycle-ci/ci/minimum-release-verification/utils/all-env.sh
setup_bosh_env

pushd git-pks-docker-bosh-release
  bosh create-release --version="${DOCKER_GIT_SHA}" --tarball pipeline.tgz
  bosh upload-release pipeline.tgz
popd
