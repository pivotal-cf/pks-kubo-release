#!/bin/bash

set -euxo pipefail

source git-boshcycle-ci/ci/utils/use-bosh.sh
source git-boshcycle-ci/ci/open-source-management/deployment-name.sh

bosh run-errand \
  -d "${DEPLOYMENT_NAME}" \
  print-component-version \
  --json \
  > linux_versions.txt

echo "Linux version output:"
jq -r .Tables[0].Rows[0].stdout linux_versions.txt > osl_linux.txt
cat osl_linux.txt
echo ""


bosh run-errand \
  -d "${DEPLOYMENT_NAME}" \
  print-kubo-windows-component-version \
  --json \
  > windows_versions.txt

echo "Windows version output:"
cat windows_versions.txt
echo ""
