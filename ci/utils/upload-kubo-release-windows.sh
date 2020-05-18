#!/bin/bash

set -euxo pipefail


source git-pks-kubernetes-release-ci/ci/utils/use-bosh.sh

pushd pks-kubernetes-windows-release
  RELEASE_TARBALL=$(ls kubo-release-*.tgz)
  bosh upload-release ${RELEASE_TARBALL}
popd
