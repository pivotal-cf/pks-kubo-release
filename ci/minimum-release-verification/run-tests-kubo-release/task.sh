#!/bin/bash

set -euxo pipefail

pushd git-pks-kubo-release
  bundle install
  rspec --format documentation
popd
