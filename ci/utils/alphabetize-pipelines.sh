#!/bin/bash

set -euo pipefail

usage() {
  echo "$0 <concourse-target-name> [<concourse-target-name2>...]"
  echo "   alphabetizes pipelines in each target"
}

alphabetize() {
  concourse_target=$1

  raw_pipeline_data=$(fly -t ${concourse_target} pipelines | sort)

  #  Split raw_pipeline_data into an array
  pipeline_rows=(); while read -r line; do pipeline_rows+=("$line"); done <<<"$raw_pipeline_data";

  order_pipelines_command="fly -t ${concourse_target} order-pipelines "
  for pipeline_row in "${pipeline_rows[@]}"
  do
    # Split row into pieces by space and take first element as pipeline name
    set $pipeline_row
    pipeline=$1
    # Append pipeline to ordering command
    order_pipelines_command="${order_pipelines_command} --pipeline ${pipeline} "
  done

  ${order_pipelines_command}
}

if [ "$#" == "0" ]; then
  usage
  exit 1
fi

while (( "$#" )); do
  alphabetize $1
  shift
done
