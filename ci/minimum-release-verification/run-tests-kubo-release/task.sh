#!/bin/bash

set -euo pipefail

pushd git-pks-kubo-release
  ./run_tests.sh
popd
