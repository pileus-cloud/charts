# Kubernetes Metrics Collector Installation Guide

Please notice that this agent should be installed **per cluster**. This is done in order to reduce the load. We are assuming that each cluster has a separate Prometheus or Thanos instance. 

## Prerequisities:

- Helm 3
- `kube-prometheus-stack` installed. See the installation steps [here](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) (also see the k8s labels collection note below).

Also agent requires Prometheus to collect k8s labels, the collection is disabled by default. To enable it you need to add and extra argument `--metric-labels-allowlist=pods=[*],nodes=[*]` to kube-state-metrics

If you are using a helm chart, add it like this:
```
kube-state-metrics:
  extraArgs:
    - --metric-labels-allowlist=pods=[*],nodes=[*]
```
and after that upgrade your prometheus stack.

If you’d like to update without using a helm chart, add it to the command like this:
```
helm upgrade <your> <other> <arguments> --set kube-state-metrics.extraArgs[0]=--metric-labels-allowlist=pods=[*],nodes=[*]
``



## Installation:


1. Add Metrics collector repo:

```bash
helm repo add anodot-cost https://pileus-cloud.github.io/charts
```

2. Create a values file and put relevant config

_values.yaml_

```yaml
# Default values for k8s-metrics-collector.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

image:
  tag: "0.3.1"

# workload: Deployment or CronJob
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
  CRON_SCHEDULE: : "0 * * * *"
  
  MONITORING: 'dummy'
  LOG_TO_CLOUD_WATCH: 'true'

  # Put your values here
  # prometheus or thanos url
  PROMETHEUS_URL: 'http://prometheus-kube-prometheus-prometheus:9090'
  # name of your EKS cluster ad it is in the aws
  CLUSTER_NAME: 'your-cluster-name'
  # if you use thanos - specify a condition to add to the queries to take data only for your specific cluster
  # METRIC_CONDITION: 'cluster="cluster_name"'
  # id of your root account
  ACCOUNT_ID: 'your-account-id'
  # id of your linked account
  LINKED_ACCOUNT_ID: 'your-linked-account-id'
  CLOUD_PROVIDER: 'aws'
  
  # Provided by anodot
  # customer name in pileus system
  CUSTOMER_NAME: 'customer-name'
  # bucket name of the Pileus destination bucket
  S3_BUCKET: 'prod-prometheus-agent'
  # access keys or role arn to access our bucket
  # ROLE_ARN: 'arn:aws:iam::1111222233334444:role/customername-agent-role'
  AWS_ACCESS_KEY_ID: 'your-access-key-id-for-the-bucket'
  AWS_SECRET_ACCESS_KEY: 'your-secret-access-key-for-the-bucket'


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

For the Deployment workload type:
```bash
kubectl get pods -n monitoring | grep k8s-metrics-collector
```

For the CronJob workload type:
```bash
kubectl get cronjob -n monitoring | grep k8s-metrics-collector
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
