#!/bin/bash

set -euxo pipefail

source git-boshcycle-ci/ci/utils/use-bosh.sh
source git-boshcycle-ci/ci/utils/kubo-sha.sh
source git-boshcycle-ci/ci/utils/kubo-windows-sha.sh
source git-boshcycle-ci/ci/open-source-management/deployment-name.sh

export NETWORK_NAME=`bosh int <(bosh cloud-config) --path /networks | yq -r '.[] | select(.name|test(".*pks-services-subnet.*")) | .name'`
export FIRST_AZ=`bosh int <(bosh cloud-config) --path /networks | yq -r '.[] | select(.name|test(".*pks-services-subnet.*")) | .subnets[0].azs[0]'`

bosh deploy \
  --non-interactive \
  --deployment="${DEPLOYMENT_NAME}" \
  --var=deployment-name="${DEPLOYMENT_NAME}" \
  --var=kubo-version="${KUBO_GIT_SHA}" \
  --var=kubo-windows-version="${KUBO_WINDOWS_GIT_SHA}" \
  --var=network-name="${NETWORK_NAME}" \
  --var=first-az="${FIRST_AZ}" \
  git-boshcycle-ci/ci/open-source-management/open-source-management-manifest.yml
