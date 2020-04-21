#!/bin/bash

set -euxo pipefail

gitHeadSha() {
  local result

  if [ -d "$1" ]
  then
    pushd "$1" > /dev/null
      result="$(git log -1 --format='%H')"
    popd > /dev/null
  else
    result=""
  fi

  echo $result
}

LINUX_GIT_SHA="$(gitHeadSha "git-pks-kubernetes-release")"
WINDOWS_GIT_SHA="$(gitHeadSha "git-pks-kubernetes-windows-release")"

export LINUX_GIT_SHA WINDOWS_GIT_SHA
