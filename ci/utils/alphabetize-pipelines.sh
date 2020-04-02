#!/bin/bash

set -euxo pipefail

# TODO: make Concourse team a parameter
CONCOURSE_TEAM="pks-bosh-lifecycle"

raw_pipeline_data=$(fly -t ${CONCOURSE_TEAM} pipelines | sort)

#  Split raw_pipeline_data into an array
pipeline_rows=(); while read -r line; do pipeline_rows+=("$line"); done <<<"$raw_pipeline_data"; declare -p pipeline_rows;

order_pipelines_command="fly -t ${CONCOURSE_TEAM} order-pipelines "
for pipeline_row in "${pipeline_rows[@]}"
do
  # Split row into pieces by space and take first element as pipeline name
  set $pipeline_row
  pipeline=$1
  # Append pipeline to ordering command
  order_pipelines_command="${order_pipelines_command} --pipeline ${pipeline} "
done

${order_pipelines_command}