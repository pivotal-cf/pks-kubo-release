#!/bin/bash

set -euxo pipefail

raw_pipeline_data=$(fly -t pks-bosh-lifecycle pipelines)

# TODO: split the raw output into an array of output lines (pipeline rows)
#  pipeline_rows=raw_pipeline_data.split()
# TODO: alphabetize

order_pipelines_command="fly -t pks-bosh-lifecycle order-pipelines "
## now loop through the pipeline rows array
for pipeline_row in "${pipeline_rows[@]}"
do
  # TODO: parse the pipeline row to get the pipeline name
  # pipeline <= pipeline_row
  order_pipelines_command="${order_pipelines_command} --pipeline ${pipeline} "
done

# TODO: run the command
echo "order_pipelines_command=[${order_pipelines_command}]"