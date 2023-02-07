# Kubernetes Metrics Collector Installation Guide

Please notice that this agent should be installed **per cluster**. This is done in order to reduce the load. We are assuming that each cluster has a separate Prometheus or Thanos instance. 

## Prerequisities:

- Helm 3
- `kube-prometheus-stack` installed. See the installation steps below.


## Installation:

1. Add Anodot repository by running next command:

```bash
helm repo add anodot https://anodot.github.io/helm-charts
```

2. Add Metrics collector repo:

```bash
helm repo add anodot-cost https://pileus-cloud.github.io/charts
```

3. Create a values file and put relevant config

_values.yaml_

```yaml
# Default values for k8s-metrics-collector.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

image:
  tag: "0.2.20"

# workload: Deployment or CronJob
workload: Deployment

environment:
  MONITORING: 'dummy'
  LOG_TO_CLOUD_WATCH: 'true'

  # Put your values here
  # prometheus or thanos url
  PROMETHEUS_URL: 'http://prometheus-kube-prometheus-prometheus:9090'
  # if you use thanos - specify a condition to add to the queriees to take data only for your specific clusteer
  # METRIC_CONDITION: 'cluster="cluster_name"'
  # name of your EKS cluster ad it is in the aws
  CLUSTER_NAME: 'your-cluster-name'
  # if you use thanos - specify a condition to add to the queriees to take data only for your specific clusteer
  # METRIC_CONDITION: 'cluster="cluster_name"'
  # id of your root account
  ACCOUNT_ID: 'your-account-id'
  # id of your linked account
  LINKED_ACCOUNT_ID: 'your-linked-account-id'
  CLOUD_PROVIDER: 'aws'
  
  # Provided by anodot
  # customer name in pileus system
  CUSTOMER_NAME: 'customer-name'
  # bucket name and region where the bucket is located for data destination 
  AWS_REGION: 'bucket-region'
  S3_BUCKET: 's3-bucket'
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
helm install k8s-metrics-collector anodot-cost/k8s-metrics-collector -f values.yaml
```

5. Verify that the pod is up and running. 
