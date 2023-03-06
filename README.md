# Kubernetes Metrics Collector Installation Guide

Please notice that this agent should be installed **per cluster**. This is done in order to reduce the load. We are assuming that each cluster has a separate Prometheus or Thanos instance. 

## Prerequisities:

- `Helm 3`
- `kube-prometheus-stack`. Installation instructions can be found [here](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) (please also notice the k8s labels collection note below).

### Minimum supported versions

Community `kube-prometheus-stack` chart - 13.11.0

Specific app versions (same as used in the chart above):

`node-exporter` - 1.0.1

`prometheus` - 2.24

`kube-state-metrics` - 1.9.7

### Labels collection
Agent requires Prometheus to collect k8s labels, the collection is disabled by default. To enable it add the extra argument `--metric-labels-allowlist=pods=[*],nodes=[*]` to `kube-state-metrics`.

If you are using a Helm chart:
```
kube-state-metrics:
  extraArgs:
    - --metric-labels-allowlist=pods=[*],nodes=[*]
```
and after that upgrade the Prometheus stack installation.

If you’d like to upgrate without using a Helm chart, add it to the command:
```
helm upgrade <your> <other> <arguments> --set kube-state-metrics.extraArgs[0]=--metric-labels-allowlist=pods=[*],nodes=[*]
```


## Installation:


1. Add Metrics collector repo:

```bash
helm repo add anodot-cost https://pileus-cloud.github.io/charts
```

2. Create a values file and put relevant config

_values.yaml_

```yaml
# This is a YAML-formatted file.

image:
  repository: public.ecr.aws/i5o6o6d7/k8s-metrics-agent
  pullPolicy: IfNotPresent
  tag: "0.3.2"

# workload type: Deployment or CronJob
workload: CronJob

CronJob:
  schedule: "0 * * * *"
  concurrencyPolicy: Forbid
  startingDeadlineSeconds: 15
  failedJobsHistoryLimit: 3
  successfulJobsHistoryLimit: 3
  activeDeadlineSeconds: 14400
  # -- Valid values: "OnFailure", "Never"
  restartPolicy: "Never"
  backoffLimit: 0

environment:
  # Needed only for the Deployment workload
  # CRON_SCHEDULE: : "0 * * * *"
  
  # Monitoring support coming soon
  MONITORING: 'none'
  LOG_TO_CLOUD_WATCH: 'true'

  # Prometheus or Thanos URL
  PROMETHEUS_URL: 'http://prometheus-kube-prometheus-prometheus:9090'
  
  # Name of the cluster that will be monitored
  CLUSTER_NAME: 'your-cluster-name'
  
  # When using Thanos specify a condition, that will filter results by labels, to fetch data only of a specific cluster
  # METRIC_CONDITION: 'cluster="cluster_name"'
  
  # ID of your AWS root account
  ACCOUNT_ID: 'account-id'
  
  # ID of your AWS linked account
  LINKED_ACCOUNT_ID: 'linked-account-id'
  
  CLOUD_PROVIDER: 'aws'
  
  # Provided by Anodot:
  
  # Bucket name of the Pileus destination bucket
  S3_BUCKET: 'prod-prometheus-agent'
  
  # Access keys or role ARN to access Pileus AWS
  # ROLE_ARN: 'arn:aws:iam::1111222233334444:role/customer-agent-role'
  AWS_ACCESS_KEY_ID: 'access-key-id'
  AWS_SECRET_ACCESS_KEY: 'secret-access-key'


podAnnotations: {}

podSecurityContext: {}
  # fsGroup: 2000

securityContext: {}
  # capabilities:
  #   drop:
  #   - ALL
  # readOnlyRootFilesystem: true
  # runAsNonRoot: true
  # runAsUser: 1000

resources: {}
  # We usually recommend not to specify default resources and to leave this as a conscious
  # choice for the user. This also increases chances charts run on environments with little
  # resources, such as Minikube. If you do want to specify resources, uncomment the following
  # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
  # limits:
  #   cpu: 100m
  #   memory: 128Mi
  # requests:
  #   cpu: 100m
  #   memory: 128Mi

nodeSelector: {}

tolerations: []

affinity: {}
```

4. Install the chart

```bash
helm upgrade --install --create-namespace -n monitoring k8s-metrics-collector anodot-cost/k8s-metrics-collector -f values.yaml
```

5. Verify that the pod is up and running. 

**For the Deployment workload type**:
```bash
kubectl -n monitoring get pods | grep k8s-metrics-collector
kubectl -n monitoring logs -f <k8s-metrics-collector-pod-name>
```

**For the CronJob workload type**:
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

### Resources required:

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
