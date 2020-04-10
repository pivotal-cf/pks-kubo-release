#!/bin/bash

set -euo pipefail

bundle install

echo "### RSpec Tests"
rspec --format documentation

echo "### Go Tests"
GOPATH=$(pwd) go test file-generator/... osl-collector/...

