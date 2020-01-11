#!/bin/bash
set -exu -o pipefail

source git-pks-kubo-release-ci/ci/scripts/lib/generate-pr.sh

pr_release() {
  version="$1"
  git_repo="$2"

  concourse_base_name="git-${git_repo}"

  cp -r "${concourse_base_name}/." "${concourse_base_name}-output"
  pushd "${concourse_base_name}-output"

  ./scripts/download_k8s_binaries $version

  if [ -n "$(git status --porcelain)" ]; then
    cat <<EOF > "config/private.yml"
blobstore:
  options:
    access_key_id: ${ACCESS_KEY_ID}
    secret_access_key: ${SECRET_ACCESS_KEY}
EOF
    bosh upload-blobs
    generate_pull_request "kubernetes" "$version" "${git_repo}" "master"
  else
    echo "Kubernetes version is already up-to-date"
  fi

  popd
}

if [ "${REPO:-}" == "windows" ]; then
  binary_directory="gcs-kubernetes-windows"
  git_repo="pks-kubo-release-windows"
else
  binary_directory="s3-kubernetes-common-core-linux"
  git_repo="pks-kubo-release"
fi

version=$(cat "$PWD/$binary_directory/version")
pr_release "$version" "$git_repo"
