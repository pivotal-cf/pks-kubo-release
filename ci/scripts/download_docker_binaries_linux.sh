#!/usr/bin/env bash
set -ex


main() {
  local staging_dir docker_version release_dir

  if [ $# -lt 2 ]; then
    echo "Usage: $(basename "$0") <DOCKER_VERSION> <RELEASE_DIR>"
    exit  1
  fi

  docker_version=$1
  release_dir=$2

  trap '{ rm -rf "$staging_dir"; }' EXIT

  pushd "$release_dir" || exit 1

    existing_docker_spec=$(bosh blobs --column path | grep "docker-" | grep -o -E "docker-([0-9]+\.)+[0-9]+")
    existing_docker_version=$(echo "$existing_docker_spec" | grep -o -E '([0-9]+\.)+[0-9]+')

    if [ "$existing_docker_version" == "$docker_version" ]; then
        echo "Docker version already up-to-date."
    else
      pushd "packages/docker" || exit 1
        # change version number found in string like DOCKER_VERSION="1.16.3"
        sed -E -i -e "s/DOCKER_VERSION=\"([0-9]+\.)+[0-9]+\"/DOCKER_VERSION=\"${docker_version}\"/" packaging
        sed -E -i -e "s/${existing_docker_spec}/docker-${docker_version}/" spec
      popd || exit 1

      wget https://download.docker.com/linux/static/stable/x86_64/docker-${docker_version}.tgz -O docker-${docker_version}.tgz

      remove_blob
      add_blob "docker-${docker_version}.tgz" "${docker_version}"
    fi
  popd || exit 1
}

remove_blob() {
  blob_name=$(bosh blobs --column path | grep "docker/docker-" | xargs)
  bosh remove-blob "$blob_name"
}

add_blob() {
  local binary_name docker_version
  binary_name="$1"
  docker_version="$2"

  bosh add-blob "docker-${docker_version}.tgz" "docker/$binary_name"
}

main "$@"
