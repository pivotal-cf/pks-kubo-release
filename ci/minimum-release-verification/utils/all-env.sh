#!/bin/bash

set -euxo pipefail

source git-kubo-odb-ci/scripts/lib/ci-helpers.sh
source git-boshcycle-ci/ci/minimum-release-verification/utils/define-git-shas-of-release.sh

export DEPLOYMENT_NAME="MINIMUM_RELEASE_VERIFICATION_DEPLOYMENT"