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
