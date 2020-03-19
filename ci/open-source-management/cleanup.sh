#!/bin/bash

set -euxo pipefail

source git-boshcycle-ci/ci/utils/cleanup-kubo.sh
source git-boshcycle-ci/ci/utils/cleanup-kubo-windows.sh
source git-boshcycle-ci/ci/open-source-management/deployment-name.sh

cleanupKubo ${DEPLOYMENT_NAME}
cleanupKuboWindows ${DEPLOYMENT_NAME}
