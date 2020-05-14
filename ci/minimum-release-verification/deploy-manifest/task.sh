#!/bin/bash

set -euxo pipefail

source git-kubo-odb-ci/scripts/lib/ci-helpers.sh
setup_bosh_env

export NETWORK_NAME=`bosh int <(bosh cloud-config) --path /networks | yq -r '.[] | select(.name|test(".*pks-services-subnet.*")) | .name'`
export FIRST_AZ=`bosh int <(bosh cloud-config) --path /networks | yq -r '.[] | select(.name|test(".*pks-services-subnet.*")) | .subnets[0].azs[0]'`

export LINUX_GIT_SHA=`cat git-pks-kubernetes-release/.git/ref`
export WINDOWS_GIT_SHA=`cat git-pks-kubernetes-windows-release/.git/ref`

bosh deploy \
  --non-interactive \
  --deployment="${DEPLOYMENT_NAME}" \
  --var=deployment-name="${DEPLOYMENT_NAME}" \
  --var=kubo-version="${LINUX_GIT_SHA}" \
  --var=kubo-windows-version="${WINDOWS_GIT_SHA}" \
  --var=network-name="${NETWORK_NAME}" \
  --var=first-az="${FIRST_AZ}" \
  git-pks-kubernetes-release-ci/ci/minimum-release-verification/manifest.yml
