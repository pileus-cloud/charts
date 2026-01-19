# Troubleshooting Empty Metrics

## Symptoms

Warning messages in logs indicating queries return no data:

```
WARNING - Prometheus query returned no data: {'query': "avg_over_time(<metric_name>{...
```

When required metrics are missing, you will see:

```
NoMetricDataException: Required metric queries returned no data: {'node_labels': "avg_over_time(kube_node_labels{...})"}.
Other queries have data, so this indicates a configuration issue.
```

## Common Causes

### 1. Metric Not Collected

The metric is not collected in your environment or not exposed by Prometheus.

**Solution:** Verify the metric exists in Prometheus:
```promql
kube_node_labels
kube_pod_labels
```

If missing, ensure `kube-state-metrics` and `kubelet` are properly configured and scraping is enabled.

### 2. Incorrect Job Name

The job collecting the metric has a non-default name.

**Default job names:**

| Component          | Default Name         |
|--------------------|----------------------|
| kube-state-metrics | `kube-state-metrics` |
| kubelet            | `kubelet`            |
| node-exporter      | `node-exporter`      |

**Solution:** Check actual job names in Prometheus:
```promql
group by (job) (kube_node_labels)
group by (job) (container_cpu_usage_seconds_total)
```

Update agent configuration with correct names:
```
KUBE_STATE_METRICS_JOB_NAME=<actual-job-name>
KUBELET_JOB_NAME=<actual-job-name>
```

### 3. Label Filter Mismatch

Custom label filters (`METRIC_CONDITION`) exclude all data.

**Solution:** Verify the filter returns data:
```promql
kube_node_labels{<your_filter>}
```

## Required Metrics

By default, the agent validates that required metrics return data. The following metrics are required:

- `node_labels`
  ```promql
  avg_over_time(kube_node_labels{node!='' ...}[...])
  ```
- `pod_labels`
  ```promql
  avg_over_time(kube_pod_labels{namespace!='',pod!='' ...}[...])
  ```

If these return empty while other queries succeed, the agent will fail with `NoMetricDataException`.

## Disabling Validation

Validation is enabled by default (`FAIL_ON_EMPTY_METRICS=true`). To disable it, set the environment variable in your Helm chart:

```yaml
env:
  - name: FAIL_ON_EMPTY_METRICS
    value: "false"
```

When disabled, empty query results will only produce warning logs without failing the agent.
