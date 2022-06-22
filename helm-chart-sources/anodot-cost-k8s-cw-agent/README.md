# Installation

## Add repository by running 

```shell
helm repo add anodot https://pileus-cloud.github.io/charts
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
helm upgrade -i anodot-cost-k8s-cw-agent -f ./values.yaml --namespace amazon-cloudwatch --create-namespace
```