#!/bin/bash
set -exu -o pipefail

source git-pks-kubo-release-ci/ci/scripts/lib/generate-pr.sh

pr_release() {
  version="$1"
  git_repo="$2"
  script_name="$3"
  base_branch="$4"

  concourse_base_name="git-${git_repo}"

  cp -r "${concourse_base_name}/." "${concourse_base_name}-output"
  pushd "${concourse_base_name}-output"

  ../git-pks-kubo-release-ci/ci/scripts/$script_name $version $(pwd)

  if [ -n "$(git status --porcelain)" ]; then
    cat <<EOF > "config/private.yml"
---
blobstore:
  options:
    credentials_source: static
    json_key: |
  $BLOBSTORE_GCS_JSON_KEY
EOF
    bosh upload-blobs
    generate_pull_request "docker" "$version" "${git_repo}" "${base_branch}"
  else
    echo "Docker version is already up-to-date"
  fi

  popd
}

main() {
  if [ "${REPO:-}" == "windows" ]; then
    git_repo="pks-kubo-release-windows"
    script_name="download_docker_binaries_windows.sh"
  else
    git_repo="pks-docker-boshrelease"
    script_name="download_docker_binaries_linux.sh"
  fi

  # BINARY_DIRECTORY should be declared in the pipeline via params
  version=$(cat "$PWD/$BINARY_DIRECTORY/version")
  pr_release "$version" "$git_repo" "$script_name" "${BASE_BRANCH}"
}

main $@