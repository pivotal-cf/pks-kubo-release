#!/usr/bin/env bash
set -eux
set -o pipefail

source /var/vcap/jobs/docker/lib/wait_for_docker.sh
source /var/vcap/jobs/load-images/bin/load_container_images.sh

docker_ctl="/var/vcap/jobs/docker/bin/ctl"
$docker_ctl start
wait_for_docker

load_containers

$docker_ctl stop