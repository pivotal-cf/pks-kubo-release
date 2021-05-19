#!/usr/bin/env bash

wait_for_containerd() {
  # this function uses the exit status of "ctr pprof" to decide to loop, so errors are acceptable
  set +e
  echo "waiting for containerd info to return successfully ..."

  containerd_info_exit_code="-1"
  startup_duration=0

  while [[ "$startup_duration" -lt 120 && "$containerd_info_exit_code" != "0" ]]; do
    # sleeping first, to allow containerd time to start up
    startup_duration=$(( startup_duration+5 ))
    sleep 5

    # this is run as sudo, and doesn't have "ctr" in the PATH
    # it also needs the host to be explicitly set so that it does not default to:
    # unix:///var/run/containerd.sock
    /var/vcap/packages/containerd/bin/ctr pprof --debug-socket=/var/vcap/sys/run/containerd/debug.sock block > /dev/null 2>&1 
    containerd_info_exit_code="$?"

    echo "Have waited $startup_duration seconds for containerd to be started"
  done

  if [ "$containerd_info_exit_code" != "0" ]
  then
    echo "Containerd is not running, exiting so that monit will restart kubelet"
    exit 1
  fi

  set -e
}

wait_for_docker() {
  # this function uses the exit status of "docker info" to decide to loop, so errors are acceptable
  set +e
  echo "waiting for docker info to return successfully ..."

  docker_info_exit_code="-1"
  startup_duration=0

  while [[ "$startup_duration" -lt 120 && "$docker_info_exit_code" != "0" ]]; do
    # sleeping first, to allow docker time to start up
    startup_duration=$(( startup_duration+5 ))
    sleep 5

    # this is run as sudo, and doesn't have "docker" in the PATH
    # it also needs the host to be explicitly set so that it does not default to:
    # unix:///var/run/docker.sock
    /var/vcap/packages/docker/bin/docker --host unix:///var/vcap/sys/run/docker/docker.sock info
    docker_info_exit_code="$?"

    echo "Have waited $startup_duration seconds for docker to be started"
  done

  if [ "$docker_info_exit_code" != "0" ]
  then
    echo "Docker is not running, exiting so that monit will restart kubelet"
    exit 1
  fi

  set -e
}

wait_for_runtime() {
  #check containerd existence
  if [ -e "/var/vcap/packages/containerd/bin/ctr" ]; then
    wait_for_containerd
  else
    wait_for_docker
  fi
}