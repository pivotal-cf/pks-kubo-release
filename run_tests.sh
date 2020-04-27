#!/bin/bash

set -euo pipefail

bundle install

echo "### RSpec Tests"
rspec --format documentation
