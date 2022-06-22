#!/usr/bin/env bash

set -u

current_dir="$(dirname "$0")"

declare -a supported_k8s_version=("1.15.0" "1.16.0" "1.18.1")

for k8s_version in "${supported_k8s_version[@]}"
do
    for d in ${current_dir}/helm-chart-sources/* ; do
        echo "Validating '${d}' against '${k8s_version}' kubernetes version"
        "${HELM}" kubeval "${d}" -v "$k8s_version"
    done
done