#!/bin/bash

set -euxo pipefail

source git-pks-kubernetes-release-ci/ci/utils/use-bosh.sh
source git-pks-kubernetes-release-ci/ci/open-source-management/deployment-name.sh

if [-d gcs-pks-kubo-release] #use tarball
then
  PKS_KUBO_VERSION=$(cat gcs-pks-kubo-release/version)
else #use final release
  files=(`ls git-pks-kubernetes-release/releases/kubo/*${VERSION}*`)
  PKS_KUBO_VERSION=$(yq -r .version ${files[-1]})
fi

if [-d gcs-pks-kubo-release-windows] #use tarball
then
  PKS_KUBO_WINDOWS_VERSION=$(cat gcs-pks-kubo-release-windows/version)
else #use final release
  files=(`ls git-pks-kubernetes-windows-release/releases/kubo-windows/*${VERSION}*`)
  PKS_KUBO_WINDOWS_VERSION=$(yq -r .version ${files[-1]})
fi

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
