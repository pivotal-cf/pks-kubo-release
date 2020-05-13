#!/bin/bash

set -euxo pipefail

source git-boshcycle-ci/ci/utils/use-bosh.sh
source git-boshcycle-ci/ci/utils/kubo-sha.sh

cleanupKubo() {
  local deployment=$1

  if [ -d "$1" ]
  then
    bosh delete-deployment \
      --non-interactive \
      --deployment="${deployment}" \
      || true
  fi
}

cleanupKuboWindows() {
  local deployment=$1

  if [ -d "$1" ]
  then
    bosh delete-deployment \
      --non-interactive \
      --deployment="${deployment}" \
      || true
  fi
}

