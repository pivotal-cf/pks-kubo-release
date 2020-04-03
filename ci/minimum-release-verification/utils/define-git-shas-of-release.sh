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

KUBO_GIT_SHA="$(gitHeadSha "git-pks-kubo-release")"
KUBO_WINDOWS_GIT_SHA="$(gitHeadSha "git-pks-kubo-release-windows")"

export KUBO_GIT_SHA KUBO_WINDOWS_GIT_SHA
