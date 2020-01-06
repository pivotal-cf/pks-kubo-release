#!/bin/bash
set -exu -o pipefail

source git-pks-kubo-release/ci/scripts/lib/generate-pr.sh

pr_release() {
  version="$1"
  release_name="$2"

  git_release_name="git-${release_name}"

  cp -r "${git_release_name}/." "${git_release_name}-output"
  pushd "${git_release_name}-output"

  ./scripts/download_k8s_binaries $version

  if [ -n "$(git status --porcelain)" ]; then
    cat <<EOF > "config/private.yml"
blobstore:
  options:
    access_key_id: ${ACCESS_KEY_ID}
    secret_access_key: ${SECRET_ACCESS_KEY}
EOF
    bosh upload-blobs
    generate_pull_request "kubernetes" "$version" "${release_name}" "master"
  else
    echo "Kubernetes version is already up-to-date"
  fi

  popd
}

if [ "${REPO:-}" == "windows" ]; then
  version=$(cat "$PWD/gcs-kubernetes-windows/version")
  pr_release "$version" "pks-kubo-release-windows"
else
  version=$(cat "$PWD/s3-kubernetes-common-core-linux/version")
  pr_release "$version" "pks-kubo-release"
fi
