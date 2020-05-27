#!/usr/bin/env bash
set -eux
set -o pipefail

function load_container_images {
  local packages_dir=${BOSH_PACKAGES_DIR:-/var/vcap/packages}
  local image_dir=${packages_dir}/images

  for filename in ${image_dir}/*.tar; do
    if [ -e "${filename}" ]; then   # guard against no files found (bash pitfall)
      /var/vcap/packages/docker/bin/docker load "${filename}"
    fi
  done

  return 0
}