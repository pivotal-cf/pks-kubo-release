#!/bin/bash
set -exu -o pipefail

pushd "git-pks-kubernetes-release"

  if [ -n "$(git status --porcelain)" ]; then
    cat <<EOF > "config/private.yml"
blobstore:
  options:
    credentials_source: static
    json_key: |
$GCS_JSON_KEY
EOF
popd

pushd "git-pks-kubernetes-windows-release"

  if [ -n "$(git status --porcelain)" ]; then
    cat <<EOF > "config/private.yml"
blobstore:
  options:
    credentials_source: static
    json_key: |
$GCS_JSON_KEY
EOF
popd