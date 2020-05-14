#!/bin/bash
set -exu -o pipefail

pushd "git-pks-kubernetes-release"

cat <<EOF > "config/private.yml"
blobstore:
  options:
    credentials_source: static
    json_key: |
$GCS_JSON_KEY
EOF
popd

pushd "git-pks-kubernetes-windows-release"

cat <<EOF > "config/private.yml"
blobstore:
  options:
    credentials_source: static
    json_key: |
$GCS_JSON_KEY
EOF
popd
