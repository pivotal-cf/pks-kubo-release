#!/bin/bash

set -euxo pipefail

source git-pks-kubernetes-release-ci/ci/utils/use-bosh.sh
source git-pks-kubernetes-release-ci/ci/open-source-management/deployment-name.sh

PKS_KUBO_VERSION=$(cat pks-kubernetes-release/version)
PKS_KUBO_WINDOWS_VERSION=$(cat pks-kubernetes-windows-release)

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
  git-pks-kubernetes-release-ci/ci/open-source-management/osm-deployment-manifest.yml
  