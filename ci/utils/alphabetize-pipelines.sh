#!/bin/bash

set -euxo pipefail

# TODO: make Concourse team a parameter
CONCOURSE_TEAM="pks-bosh-lifecycle"

raw_pipeline_data=$(fly -t ${CONCOURSE_TEAM} pipelines)

# TODO: split the raw output into an array of output lines (pipeline rows)
#  pipeline_rows <= raw_pipeline_data
# TODO: alphabetize pipeline_rows

order_pipelines_command="fly -t ${CONCOURSE_TEAM} order-pipelines "
for pipeline_row in "${pipeline_rows[@]}"
do
  # TODO: parse the pipeline row to get the pipeline name
  # pipeline <= pipeline_row
  order_pipelines_command="${order_pipelines_command} --pipeline ${pipeline} "
done

# TODO: run the ordering command
echo "order_pipelines_command=[${order_pipelines_command}]"