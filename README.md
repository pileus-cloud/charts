# Kubernetes Metrics Collector Installation Guide

Please notice that this agent should be installed **per cluster**. This is done in order to reduce the load. We are assuming that each cluster has a separate Prometheus or Thanos instance. 

- [Prerequisites](#prerequisites)
  * [Minimum supported versions](#minimum-supported-versions)
  * [Labels collection](#labels-collection)
- [Installation](#installation)
  * [Storing secrets](#storing-secrets)
- [Resources required](#resources-required)

## Prerequisites

- `Helm 3`
- `kube-prometheus-stack`. Installation instructions can be found [here](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack), please also notice the k8s labels collection note below. Also, you might want to disable installation of Grafana and alertmanager since they are not used by our app. You can do it by setting `enabled: false` in the kube-prometheus-stack values file for them.
- k8s-metrics-collector should be able to access our AWS from your k8s cluster where it is installed. Secrets needed for authentication will be provided by us.

### Minimum supported versions

- Community `kube-prometheus-stack` chart - 13.11.0

Specific app versions (same as used in the chart above):

- `node-exporter` - 1.0.1
- `prometheus` - 2.24
- `kube-state-metrics` - 1.9.7

### Labels collection
Agent requires Prometheus to collect k8s labels, the collection is disabled by default. To enable it add the extra argument `--metric-labels-allowlist=pods=[*],nodes=[*]` to `kube-state-metrics`.

If you are using a Helm chart, add the following to the values file:
```
kube-state-metrics:
  extraArgs:
    - --metric-labels-allowlist=pods=[*],nodes=[*]
```

If you’d like to upgrade without using a custom `values.yaml` file (not recommended), add it in the command line:
```
helm upgrade <your> <other> <arguments> --set kube-state-metrics.extraArgs[0]=--metric-labels-allowlist=pods=[*],nodes=[*]
```


## Installation

1. Add Metrics collector repo:

```bash
helm repo add anodot-cost https://pileus-cloud.github.io/charts
```

2. Put relevant configuration in [values.yaml](https://github.com/pileus-cloud/charts/blob/main/helm-chart-sources/k8s-metrics-collector/values.yaml) file. In most cases only environment variables need to be set, they are marked with comments in the values file.

3. Install the chart

```bash
helm upgrade --install --create-namespace -n monitoring k8s-metrics-collector anodot-cost/k8s-metrics-collector -f values.yaml
```

4. Verify that the pod is up and running. 

For the Deployment workload type:
```bash
kubectl -n monitoring get pods | grep k8s-metrics-collector
kubectl -n monitoring logs -f <k8s-metrics-collector-pod-name>
```

For the CronJob workload type:
```bash
kubectl -n monitoring get cronjob | grep k8s-metrics-collector
```
Usually the CronJob runs hourly, so it will create the pod only at 0 minutes of the next hour. In order to verify installation you can create a job manually:
```
kubectl -n monitoring create job --from=cronjob/k8s-metrics-collector k8s-metrics-collector-manual-run
```
And then
```
kubectl get pods -n monitoring | grep k8s-metrics-collector
kubectl -n monitoring logs -f <k8s-metrics-collector-pod-name>
```

### Storing secrets
It is recommended to use [external secrets](https://github.com/external-secrets/external-secrets), [helm secrets](https://github.com/jkroepke/helm-secrets) or a similar tool to store secrets encrypted and use them in the values file.

## Resources required

Recommended limits/requests:

```
    Limits:
      cpu:     100m
      memory:  500Mi
    Requests:
      cpu:     100m
      memory:  500Mi
```
This was tested on ~100000 metrics. The agent might require a larger amount of resources in case of having to process a larger amount of data.
