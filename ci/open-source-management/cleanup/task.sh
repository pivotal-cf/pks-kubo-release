#!/bin/bash

set -euxo pipefail

source git-pks-kubernetes-release-ci/ci/utils/cleanup-kubo.sh
source git-pks-kubernetes-release-ci/ci/open-source-management/deployment-name.sh

cleanupKubo ${DEPLOYMENT_NAME}
cleanupKuboWindows ${DEPLOYMENT_NAME}
