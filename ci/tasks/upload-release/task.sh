#!/bin/bash

set -euxo pipefail

source git-kubo-odb-ci/scripts/lib/ci-helpers.sh

export GIT_SHA=`cat bosh-release/.git/ref`

setup_bosh_env

pushd bosh-release
  cat <<EOF > "config/private.yml"
---
blobstore:
  options:
    credentials_source: static
    json_key: |
$GCS_JSON_KEY
EOF

  bosh create-release --version="${GIT_SHA}" --tarball pipeline.tgz
  bosh upload-release pipeline.tgz
popd
