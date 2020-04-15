#!/bin/bash
set -exu -o pipefail

source git-pks-kubo-release-ci/ci/scripts/lib/generate-pr.sh

download_and_add_blob_and_commit() {
  local version script_name component
  version="$1"
  script_name="$2"
  component="$3"

  ../git-pks-kubo-release-ci/ci/scripts/$script_name $version "$(pwd)"

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
    commit "$component" "$version"
  else
    echo "Component version is already up-to-date"
  fi
}

determine_docker_version() {
  local kubernetes_version minor_docker_version docker_version
  kubernetes_version="$1"

  curl -o k8s-dependencies.yml https://raw.githubusercontent.com/kubernetes/kubernetes/v${kubernetes_version}/build/dependencies.yaml
  minor_docker_version=$(cat k8s-dependencies.yml | yq '.dependencies[] | select(.name == "docker") | .version')
  curl -o DockerMsftIndex.json https://dockermsft.azureedge.net/dockercontainer/DockerMsftIndex.json
  docker_version=$(cat DockerMsftIndex.json | jq ".channels[\"${minor_docker_version}\"].version" -r)

  echo "$docker_version"
}

main() {
  local git_repo k8s_script_name docker_script_name matched_k8s_version google_k8s_version docker_version

  # BINARY_DIRECTORY should be declared in the pipeline via params
  matched_k8s_version=$(cat "$PWD/$BINARY_DIRECTORY/version")
  google_k8s_version="$matched_k8s_version"

  if [ "${REPO:-}" == "windows" ]; then
    git_repo="pks-kubo-release-windows"
    k8s_script_name="download_k8s_binaries_windows"
    docker_script_name="download_docker_binaries_windows.sh"
  else
    git_repo="pks-kubo-release"
    docker_script_name="download_docker_binaries_linux.sh"
    if [ "false" == "$USE_COMMON_CORE" ]; then
      k8s_script_name="download_k8s_binaries_google"
    else
      k8s_script_name="download_k8s_binaries_common_core"
      google_k8s_version=$(echo $matched_k8s_version | cut -d"+" -f1)
    fi
  fi

  docker_version=$(determine_docker_version "$google_k8s_version")

  # this is tightly coupled with the name of the resources declared in the pipeline yml
  concourse_base_name="git-${git_repo}"
  pushd "${concourse_base_name}"

    create_branch "kubernetes" "$matched_k8s_version"
    setup_git_config

    download_and_add_blob_and_commit "$matched_k8s_version" "$k8s_script_name"  "kubernetes"
    if [[ "$BUMP_DOCKER" == "true" ]]; then
      download_and_add_blob_and_commit "$docker_version" "$docker_script_name" "docker"
    fi

    # if either of the previous calls to download_and_add_blob_and_commit caused commits, push them
    if ! git diff-index --quiet "${BASE_BRANCH}" --; then
      setup_ssh
      push_current_branch
      create_pr_through_curl "kubernetes" "$matched_k8s_version" "${BASE_BRANCH}" "${git_repo}"
    else
      echo "All components already up-to-date"
    fi

  popd
}

main $@