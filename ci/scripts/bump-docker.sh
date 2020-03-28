#!/bin/bash
set -exu -o pipefail

source git-pks-kubo-release-ci/ci/scripts/lib/generate-pr.sh

pr_release() {
  version="$1"
  git_repo="$2"
  script_name="$3"

  concourse_base_name="git-${git_repo}"

  pushd "${concourse_base_name}-output"

  ../git-pks-kubo-release-ci/ci/scripts/$script_name $version $(pwd)

  if [ -n "$(git status --porcelain)" ]; then
    cat <<EOF > "config/private.yml"
---
blobstore:
  options:
    credentials_source: static
    json_key: |
$GCS_JSON_KEY
EOF
    bosh upload-blobs
    push_to_current_branch "docker" "$version"
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
  kubernetes_version=$(cat "$PWD/$BINARY_DIRECTORY/version")
  curl -o k8s-dependencies.yml https://raw.githubusercontent.com/kubernetes/kubernetes/v${kubernetes_version}/build/dependencies.yaml
  minor_docker_version=$(cat k8s-dependencies.yml | yq '.dependencies[] | select(.name == "docker") | .version')
  curl -o DockerMsftIndex.json https://dockermsft.azureedge.net/dockercontainer/DockerMsftIndex.json
  docker_version=$(cat DockerMsftIndex.json | jq ".channels[\"${minor_docker_version}\"].version" -r)
  pr_release "$docker_version" "$git_repo" "$script_name"
}

main $@