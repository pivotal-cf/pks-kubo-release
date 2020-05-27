#!/usr/bin/env bash
set -eux
set -o pipefail

source /var/vcap/jobs/docker/lib/wait_for_docker.sh
source /var/vcap/jobs/load-images/bin/load_container_images.sh

docker_ctl="/var/vcap/jobs/docker/bin/ctl"
# start docker
$docker_ctl start
wait_for_docker

# load images for directory
load_container_images

# kill docker and ensure PID file is deleted
$docker_ctl stop
# TODO: wait for docker to have stopped