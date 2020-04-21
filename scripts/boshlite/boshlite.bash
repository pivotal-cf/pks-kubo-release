#!/bin/bash
# run me from scripts/boshlite/
# set up bosh lite via https://bosh.io/docs/bosh-lite/
# IMPORTANT: virtual box must be 6.0.x or EARLIER!!!!!!!!!  (6.1 doesn't work)

set -euxo pipefail

bosh -e vbox upload-stemcell   \
    https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-xenial-go_agent?v=456.30

export NETWORK_NAME=default
export FIRST_AZ=z1

export DEPLOYMENT_NAME=kubo
export LINUX_GIT_SHA=latest # kubo/1.7.0-build.76+dev.1

bosh -e vbox deploy \
  --non-interactive \
  --deployment="${DEPLOYMENT_NAME}" \
  --var=deployment-name="${DEPLOYMENT_NAME}" \
  --var=kubo-version="${LINUX_GIT_SHA}" \
  --var=network-name="${NETWORK_NAME}" \
  --var=first-az="${FIRST_AZ}" \
  manifest.yml
