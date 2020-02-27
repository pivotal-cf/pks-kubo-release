#!/bin/bash

set -euxo pipefail

source git-boshcycle-ci/ci/minimum-release-verification/utils/all-env.sh
setup_bosh_env

export NETWORK_NAME=`bosh int <(bosh cloud-config) --path /networks | yq -r '.[] | select(.name|test(".*pks-services-subnet.*")) | .name'`
export FIRST_AZ=`bosh int <(bosh cloud-config) --path /networks | yq -r '.[] | select(.name|test(".*pks-services-subnet.*")) | .subnets[0].azs[0]'`

bosh deploy \
  --non-interactive \
  --deployment="${DEPLOYMENT_NAME}" \
  --var=deployment-name="${DEPLOYMENT_NAME}" \
  --var=kubo-version="${KUBO_GIT_SHA}" \
  --var=kubo-windows-version="${KUBO_WINDOWS_GIT_SHA}" \
  --var=docker-version="${DOCKER_GIT_SHA}" \
  --var=network-name="${NETWORK_NAME}" \
  --var=first-az="${FIRST_AZ}" \
  git-boshcycle-ci/ci/minimum-release-verification/manifest.yml
