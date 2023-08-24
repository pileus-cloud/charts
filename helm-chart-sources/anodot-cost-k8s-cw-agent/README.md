# Introduction

This Helm chart is for the installation of AWS's CloudWatch-Agent for Kubernetes.

This is an official AWS release for a K8S agent deployed as DaemonSet that collects metrics from the cluster, which is
used by Anodot-Costs to analyze cluster usage and allocate cloud costs to its components.

This chart includes configuration settings that disables extended metrics (enabled by default in AWS's official
distribution) which are very costly and not required for Anodot's solution for usage and costs analysis. 

# Installation

## Add or update the Anodot repository 

Add the Anodot repository by running:
```shell
helm repo add anodot https://pileus-cloud.github.io/charts
```

If it was already added before, make sure it is updated by running:

```shell
helm repo update anodot
```

## Running installation
1. Create `values.yaml` file and set required variables

```yaml
config:
  clusterName: "REPLACE_ME"
  clusterRegion: "us-east-1"
```

2. Run installation
```shell
helm upgrade -i anodot-cost-k8s-cw-agent anodot/anodot-cost-k8s-cw-agent -f ./values.yaml --namespace amazon-cloudwatch --create-namespace
```
