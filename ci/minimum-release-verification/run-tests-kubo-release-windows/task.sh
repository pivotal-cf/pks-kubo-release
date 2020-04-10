#!/bin/bash

set -euo pipefail

pushd git-pks-kubo-release-windows
  ./run_tests.sh
popd

