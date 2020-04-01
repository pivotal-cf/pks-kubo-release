#!/bin/bash

set -euxo pipefail


source git-boshcycle-ci/ci/utils/use-bosh.sh

pushd gcs-pks-kubo-release
  RELEASE_TARBALL=$(ls kubo-release-*.tgz)
  bosh upload-release ${RELEASE_TARBALL}
popd
