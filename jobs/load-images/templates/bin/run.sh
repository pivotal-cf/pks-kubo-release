#!/usr/bin/env bash
set -eux
set -o pipefail

source /var/vcap/jobs/load-images/bin/load_container_images.sh

# TODO: verify it's ok to assume docker is running
load_container_images