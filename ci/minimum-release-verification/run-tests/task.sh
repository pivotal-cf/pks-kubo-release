#!/bin/bash

set -euxo pipefail

source git-boshcycle-ci/ci/minimum-release-verification/utils/all-env.sh
setup_bosh_env

bosh run-errand \
  -d "${DEPLOYMENT_NAME}" \
  print-component-version \
  --json \
  > linux_versions.txt

echo "Linux version output:"
cat linux_versions.txt
echo ""

bosh run-errand \
  -d "${DEPLOYMENT_NAME}" \
  print-kubo-windows-component-version \
  --json \
  > windows_versions.txt

# stdout will be 'Kubernetes v1.15.5'
# cut will trim that down to 1.15.5
WINDOWS_VERSION="$(cat windows_versions.txt | \
  jq .Tables[0].Rows[0].stdout --raw-output | \
  cut -d'v' -f2)"

# stdout will be OSM format yml, such as:
# other:common-core-kubernetes:1.15.5:
#  name: kubernetes
#  version: 1.15.5
#  repository: Other
#  license: Apache2.0
#  other-distribution: /tmp/osl/v1.15.5.tar.gz
#  url: https://github.com/kubernetes/kubernetes/archive/v1.15.5.tar.gz
# grep finds the header line
# cut trims down to 1.15.5
LINUX_VERSION="$(cat linux_versions.txt | \
  jq .Tables[0].Rows[0].stdout --raw-output | \
  grep '^other:common-core-kubernetes:' | \
  cut -d':' -f3)"

exit_code=0

if [ "$WINDOWS_VERSION" == "$LINUX_VERSION" ]
then
  echo "Versions match! $LINUX_VERSION"
  echo ""
else
  echo "********************************************"
  echo "ERROR: Version mismatch!  Linux: $LINUX_VERSION, Windows: $WINDOWS_VERSION"
  echo "********************************************"
  echo ""
  exit_code=1
fi

bosh run-errand \
  -d "${DEPLOYMENT_NAME}" \
  expose-versions \
  --json \
  > expose_versions.txt

EXPOSED_KUBERNETES_VERSION="$(cat expose_versions.txt | \
  jq .Tables[0].Rows[0].stdout --raw-output | \
  jq '.["kubernetes-version"]' --raw-output)"

if [ "$LINUX_VERSION" == "$EXPOSED_KUBERNETES_VERSION" ]
then
  echo "Exposed version matches shipped Linux version! $LINUX_VERSION"
  echo ""
else
  echo "********************************************"
  echo "ERROR: Version mismatch!  Linux: $LINUX_VERSION, Exposed: $EXPOSED_KUBERNETES_VERSION"
  echo "********************************************"
  echo ""
  exit_code=1
fi

exit $exit_code
