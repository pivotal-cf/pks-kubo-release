#!/bin/bash

set -euo pipefail

pushd git-pks-kubernetes-windows-release
  ./run_tests.sh
popd

