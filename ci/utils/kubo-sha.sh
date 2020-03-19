#!/bin/bash

set -euxo pipefail

source git-boshcycle-ci/ci/utils/sha.sh
export KUBO_GIT_SHA="$(gitHeadSha "git-pks-kubo-release")"