#!/bin/bash

set -euxo pipefail

# define KUBO_GIT_SHA as latest commit
source git-boshcycle-ci/ci/minimum-release-verification/utils/all-env.sh
setup_bosh_env

pushd git-pks-kubo-release
  cat <<EOF > "config/private.yml"
---
blobstore:
  options:
    credentials_source: static
    json_key: |
$GCS_JSON_KEY
EOF

  bosh create-release --version="${KUBO_GIT_SHA}" --tarball pipeline.tgz
  bosh upload-release pipeline.tgz
popd
