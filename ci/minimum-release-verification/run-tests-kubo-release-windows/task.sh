#!/bin/bash

set -euxo pipefail

pushd git-pks-kubo-release-windows
  bundle install
  rspec --format documentation
popd

