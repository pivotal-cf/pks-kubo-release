#!/bin/bash

set -euxo pipefail

source git-boshcycle-ci/ci/utils/use-bosh.sh

bosh run-errand \
  -d "DEPLOYMENT_OSM" \
  print-component-version \
  --json \
  > linux_versions.txt

echo "Linux version output:"
cat linux_versions.txt
echo ""

bosh run-errand \
  -d "DEPLOYMENT_OSM" \
  print-kubo-windows-component-version \
  --json \
  > windows_versions.txt

echo "Windows version output:"
cat windows_versions.txt
echo ""
