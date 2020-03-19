#!/bin/bash

set -euxo pipefail

source git-boshcycle-ci/ci/utils/cleanup-kubo.sh
source git-boshcycle-ci/ci/utils/cleanup-kubo-windows.sh

cleanupKubo DEPLOYMENT_OSM
cleanupKuboWindows DEPLOYMENT_OSM
