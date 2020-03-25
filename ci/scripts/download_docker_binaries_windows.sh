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

  staging_dir=$(mktemp -d)

  trap '{ rm -rf "$staging_dir"; }' EXIT

  pushd "$release_dir" || exit 1
    # the zip file used by windows has hyphens instead of dots in the version, so it looks like docker-19-03-5.zip
    # this has subtle implications on the regexes and logic used here compared to the linux script
    existing_docker_spec=$(bosh blobs --column path | grep "docker-windows" | grep -o -E "docker-([0-9]+-)+[0-9]+")
    existing_docker_version=$(echo "$existing_docker_spec" | grep -o -E '([0-9]+\-)+[0-9]+')
    hyphenated_docker_version=$(echo "$docker_version" | sed "s/\\./-/g")

    if [ "$existing_docker_version" == "$hyphenated_docker_version" ]; then
        echo "Docker version already up-to-date."
    else
      zip_url=$(curl https://dockermsft.azureedge.net/dockercontainer/DockerMsftIndex.json \
        | jq ".versions.\"$docker_version\".url" -r)

      wget -O "${staging_dir}/docker-${hyphenated_docker_version}.zip" "$zip_url"

      remove_blob
      add_blob "${staging_dir}" "docker-${hyphenated_docker_version}.zip"
    fi
  popd || exit 1
}

remove_blob() {
  blob_name=$(bosh blobs --column path | grep "docker-windows/docker-" | xargs)
  bosh remove-blob "$blob_name"
}

add_blob() {
  local staging_dir binary_name
  binary_name="$1"

  bosh add-blob "${staging_dir}/${binary_name}" "docker-windows/$binary_name"
}

main "$@"
