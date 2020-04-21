#!/bin/bash

set -euo pipefail

pushd bosh-release
  ./run_tests.sh
popd
