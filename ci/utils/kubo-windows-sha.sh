#!/bin/bash

set -euxo pipefail

source git-boshcycle-ci/ci/utils/sha.sh
export KUBO_WINDOWS_GIT_SHA="$(gitHeadSha "git-pks-kubo-release-windows")"