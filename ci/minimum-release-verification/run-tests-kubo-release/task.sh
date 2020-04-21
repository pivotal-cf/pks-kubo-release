#!/bin/bash

set -euo pipefail

pushd git-pks-kubernetes-release
  ./run_tests.sh
popd
