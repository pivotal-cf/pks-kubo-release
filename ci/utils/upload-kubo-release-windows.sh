#!/bin/bash

set -euxo pipefail


source git-boshcycle-ci/ci/utils/use-bosh.sh

pushd git-pks-kubo-release-windows
  RELEASE_TARBALL=$(ls kubo-release-*.tgz)
  bosh upload-release ${RELEASE_TARBALL}
popd
