#!/bin/bash

set -euxo pipefail

source git-boshcycle-ci/ci/utils/use-bosh.sh
source git-boshcycle-ci/ci/open-source-management/deployment-name.sh

PKS_KUBO_VERSION=$(cat gcs-pks-kubo-release/version)
PKS_KUBO_WINDOWS_VERSION=$(cat gcs-pks-kubo-release-windows/version)

export NETWORK_NAME=`bosh int <(bosh cloud-config) --path /networks | yq -r '.[] | select(.name|test(".*pks-services-subnet.*")) | .name'`
export FIRST_AZ=`bosh int <(bosh cloud-config) --path /networks | yq -r '.[] | select(.name|test(".*pks-services-subnet.*")) | .subnets[0].azs[0]'`

bosh deploy \
  --non-interactive \
  --deployment="${DEPLOYMENT_NAME}" \
  --var=deployment-name="${DEPLOYMENT_NAME}" \
  --var=kubo-version="${PKS_KUBO_VERSION}" \
  --var=kubo-windows-version="${PKS_KUBO_WINDOWS_VERSION}" \
  --var=network-name="${NETWORK_NAME}" \
  --var=first-az="${FIRST_AZ}" \
  git-boshcycle-ci/ci/open-source-management/open-source-management-manifest.yml
