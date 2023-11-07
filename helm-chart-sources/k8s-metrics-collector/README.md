# Prometheus-Agent for Anodot-Cost

## Introduction

This Helm chart is for the installation of Anodot's Prometheus-Agent for Kubernetes.

This agent is deployed as ChronJob and collects metrics of the cluster from Prometheus, and sends them to Anodot, where
it is then being analyzed for usage and cloud costs allocation to the cluster's components. 


## Table of contents

1. [Prerequisites](#prerequisites)
   1. [Known supported Prometheus versions](#known-supported-prometheus-versions)
   2. [Required metrics](#required-metrics)
      1. [Labels collection](#labels-collection)
2. [Installation](#installation)
3. [Validation & Troubleshooting](#validation--troubleshooting)

## Prerequisites

The agent has to be installed **per cluster**.  In case metrics from multiple clusters are stored in the same metrics repository, there should be an agent instance for each cluster, where each agent is [configured](values.yaml) to match metrics from a single cluster. 

The followings are required before installing Prometheus-Agent for Anodot-Cost:
- `Helm 3`
- `prometheus` or a similar service with accessible Prometheus-query API endpoint
- All the [specified metrics](#required-metrics) are available
- Anodot Access Key for uploading collected metrics (should be provided to you by Anodot)

### Known supported Prometheus versions

- `prometheus` 2.24 and above
- `kube-state-metrics` 1.9.7 and above

Both of these components are included in Community `kube-prometheus-stack` chart - 13.11.0

### Required metrics

The following is a list of mandatory metrics that are collected by the agent.

All of them should be available by default when installing `kube-prometheus-stack`, except node labels (see [labels collection](#labels-collection)).


| Metric                                 | Responsible job    |
|----------------------------------------|--------------------|
| container_cpu_usage_seconds_total      | kubelet            |
| container_memory_usage_bytes           | kubelet            |
| container_network_receive_bytes_total  | kubelet            |
| container_network_transmit_bytes_total | kubelet            |
| kube_node_info                         | kube-state-metrics |
| kube_node_labels                       | kube-state-metrics |
| kube_node_status_capacity              | kube-state-metrics |
| kube_pod_completion_time               | kube-state-metrics |
| kube_pod_container_info                | kube-state-metrics |
| kube_pod_container_resource_limits     | kube-state-metrics |
| kube_pod_container_resource_requests   | kube-state-metrics |
| kube_pod_created                       | kube-state-metrics |
| kube_pod_info                          | kube-state-metrics |
| kube_pod_labels                        | kube-state-metrics |
| kube_replicaset_owner                  | kube-state-metrics |


#### Labels collection
Node labels are required, and their collection is not enabled by default when installing Prometheus.
Enabling it requires adding the extra argument `--metric-labels-allowlist=pods=[*],nodes=[*]` to `kube-state-metrics`.

If you are using a Helm chart, this line can be added to the `values.yaml` file in this hierarchy,
```yaml
kube-state-metrics:
  extraArgs:
    - --metric-labels-allowlist=pods=[*],nodes=[*]
```
or can be set directly from the command line as a set argument for a helm upgrade comment (not recommended, as this will
might be overridden by future upgrades):
```bash
$ helm upgrade <PROMETHEUS RELEASE> <OTHER OPTIONAL ARGS> --set kube-state-metrics.extraArgs[0]=--metric-labels-allowlist=pods=[*],nodes=[*]
```


## Installation

1. Add anodot-cost Helm repository:
   ```bash
   $ helm repo add anodot-cost https://pileus-cloud.github.io/charts
   ```
   If it was already added before, make sure it's updated by running:
   ```bash
   $ helm repo update anodot-cost
   ```

2. Set the required parameters in the [values.yaml](values.yaml) file and save a copy locally (preferably containing just the modified values). Make sure to replace all the relevant values according to the comments for each value, including the Anodot access key.
   * Alternatively, you can set any value as a set argument in the `helm upgrade` command. You can also use a method for [storing secrets safely](storing-secrets.md) such as [external-secrets](https://external-secrets.io/).

3. Install the k8s-metrics-collector chart, where `values.yaml` is the modified file (specify a path if needed):
   ```bash
   $ helm upgrade --install --create-namespace -n <NAMESPACE> k8s-metrics-collector anodot-cost/k8s-metrics-collector -f values.yaml
   ```
   Where `<NAMESPACE>` is to be replaced with the namespace for the agent.


## Validation & Troubleshooting
The default configuration for the agent is a CronJob which is scheduled to run hourly every X:00:00, therefore it might take up to an hour until the agent actually runs.

To avoid the wait for the next hour to start, you can create a job manually:
```bash
$ kubectl -n <NAMESPACE> create job --from=cronjob/k8s-metrics-collector k8s-metrics-collector-manual-run
```
Verify that an agent pod ran successfully and check its logs:
```bash
# Identify the name of the agent pod:
$ kubectl get pods -n <NAMESPACE> | grep k8s-metrics-collector
# Retrieve the agent logs (replace <POD-NAME>):
$ kubectl logs -n <NAMESPACE> <POD-NAME>
```
A typical log of an agent run sequence looks like this:
```
<timestamp> - INFO - Agent configuration: { ..... }
<timestamp> - INFO - ---- STARTING ITERATION ----
...
<timestamp> - INFO - <metric name #1> took <seconds>
<timestamp> - INFO - <metric name #2> took <seconds>
<timestamp> - INFO - <metric name #3> took <seconds>
...
```
This structure, where only INFO lines are shown, is usually an indication that the agent works as expected.

If you see a fatal error, it usually indicates a problem in the configuration. The error message may indicate the source of the issue. Some of the known cases include:
* Wrong Prometheus server URL (PROMETHEUS_URL)
* Missing required authentication parameters such as user and password (USERNAME & PASSWORD) or request headers (REQUEST_HEADERS)
* Malformed/invalid values in some parameters (e.g. CLOUD_PROVIDER, METRIC_CONDITION, REQUEST_HEADERS). Follow the example or the documentation of those parameters if used.

If you see warning lines of the following format reoccurring in every run, it's likely to indicate an issue:
```
<timestamp> - WARNING - Prometheus query returned no data: {'query': "avg_over_time(<metric name>{ ...
```
The cause of these issues is usually one of the following:
* The metric is not collected in your environment, or not exposed by the Prometheus server. In this case you'll need to adjust your environment so that these metrics are properly accessible.
* The job responsible for collecting and generating the specified metric is not named as the default (as listed [here](#required-metrics)). In this case, the agent [configuration](values.yaml) has to specify the correct names (for parameters KUBE_STATE_METRICS_JOB_NAME/KUBELET_JOB_NAME).
