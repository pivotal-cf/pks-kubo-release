#!/bin/bash

set -euxo pipefail

source git-boshcycle-ci/ci/minimum-release-verification/utils/all-env.sh
setup_bosh_env

pushd git-pks-cfcr-etcd-release
  bosh create-release --version="${ETCD_GIT_SHA}" --tarball pipeline.tgz
  bosh upload-release pipeline.tgz
popd
