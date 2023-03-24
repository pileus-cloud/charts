# k8s-metrics-collector

![Version: 0.1.7](https://img.shields.io/badge/Version-0.1.7-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.3.4](https://img.shields.io/badge/AppVersion-0.3.4-informational?style=flat-square)

A Helm chart for Kubernetes

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| CronJob.activeDeadlineSeconds | int | `14400` |  |
| CronJob.backoffLimit | int | `0` |  |
| CronJob.concurrencyPolicy | string | `"Forbid"` |  |
| CronJob.failedJobsHistoryLimit | int | `3` |  |
| CronJob.restartPolicy | string | `"Never"` | Valid values: "OnFailure", "Never" |
| CronJob.schedule | string | `"0 * * * *"` |  |
| CronJob.startingDeadlineSeconds | int | `15` |  |
| CronJob.successfulJobsHistoryLimit | int | `3` |  |
| affinity | object | `{}` |  |
| configmap.enabled | bool | `false` |  |
| configmap.files[0].data.metric_queries | string | `"{\n  \"node_instances\": \"avg_over_time(node_dmi_info[%I%])\",\n  \"node_properties\": \"avg_over_time(kube_node_info[%I%])\",\n  \"node_cpu_limit\": \"avg_over_time(kube_node_status_capacity{resource='cpu'}[%I%]) * 1000\",\n  \"node_cpu_request\": \"sum(avg_over_time(kube_pod_container_resource_requests{resource='cpu'}[%I%])) by (node) * 1000\",\n  \"node_memory_limit\": \"avg_over_time(node_memory_MemTotal_bytes[%I%])\",\n  \"node_memory_request\": \"sum(avg_over_time(kube_pod_container_resource_requests{resource='memory'}[%I%])) by (node)\",\n  \"pod_properties\": \"avg_over_time(kube_pod_info[%I%])\",\n  \"pod_number_of_containers\": \"sum(avg_over_time(kube_pod_container_info[%I%])) by (pod,namespace)\",\n  \"pod_cpu_limit\": \"sum(avg_over_time(kube_pod_container_resource_limits{resource='cpu'}[%I%])) by (node,pod,namespace) * 1000\",\n  \"pod_cpu_request\": \"sum(avg_over_time(kube_pod_container_resource_requests{resource='cpu'}[%I%])) by (node,pod,namespace) * 1000\",\n  \"pod_cpu_usage_total\": \"sum(rate(container_cpu_usage_seconds_total[%I%])) by (node,pod,namespace) * 1000\",\n  \"pod_memory_limit\": \"sum(avg_over_time(kube_pod_container_resource_limits{resource='memory'}[%I%])) by (node,pod,namespace)\",\n  \"pod_memory_request\": \"sum(avg_over_time(kube_pod_container_resource_requests{resource='memory'}[%I%])) by (node,pod,namespace)\",\n  \"pod_memory_usage\": \"sum(avg_over_time(container_memory_usage_bytes[%I%])) by (node,pod,namespace)\",\n  \"pod_network_rx_bytes\": \"sum(rate(container_network_receive_bytes_total[%I%])) by (node,pod,namespace)\",\n  \"pod_network_tx_bytes\": \"sum(rate(container_network_transmit_bytes_total[%I%])) by (node,pod,namespace)\",\n  \"pod_labels\": \"avg_over_time(kube_pod_labels[%I%])\",\n  \"pod_creation_timestamp\": \"kube_pod_created\",\n  \"pod_completion_timestamp\": \"kube_pod_completion_time\"\n}"` |  |
| configmap.files[0].mountPath | string | `"/usr/src/app/src/agent/data/metric_queries.json"` |  |
| environment.ACCOUNT_ID | string | `"<ID of your AWS root account>"` |  |
| environment.CLOUD_PROVIDER | string | `"aws"` |  |
| environment.CLUSTER_NAME | string | `"<name of the cluster the chart is being installed to>"` |  |
| environment.LINKED_ACCOUNT_ID | string | `"<ID of your AWS linked account which owns the cluster>"` |  |
| environment.LOG_TO_CLOUD_WATCH | string | `"true"` |  |
| environment.MONITORING | string | `"none"` |  |
| environment.PROMETHEUS_URL | string | `"http://prometheus-kube-prometheus-prometheus:9090"` |  |
| environment.S3_BUCKET | string | `"prod-prometheus-agent"` |  |
| environmentVars.type | string | `"env"` |  |
| externalSecret.enabled | bool | `true` |  |
| externalSecret.refreshInterval | string | `"1h"` |  |
| externalSecret.secretStoreRef.kind | string | `"SecretStore"` |  |
| externalSecret.secretStoreRef.name | string | `"anodot"` |  |
| externalSecret.secrets.AWS_ACCESS_KEY_ID.key | string | `"env/secret_name_cloud"` |  |
| externalSecret.secrets.AWS_ACCESS_KEY_ID.property | string | `"aws_access_key_id"` |  |
| externalSecret.secrets.AWS_SECRET_ACCESS_KEY.key | string | `"env/secret_name_cloud"` |  |
| externalSecret.secrets.AWS_SECRET_ACCESS_KEY.property | string | `"aws_secret_access_key"` |  |
| externalSecret.target.name | string | `"anodot"` |  |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"public.ecr.aws/i5o6o6d7/k8s-metrics-agent"` |  |
| image.tag | string | `"0.3.5"` |  |
| imagePullSecrets | list | `[]` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| prometheusrule.enabled | bool | `false` |  |
| prometheusrule.groups[0].name | string | `"k8s-metrics-collector"` |  |
| prometheusrule.groups[0].rules[0].expr | string | `"node_memory_MemTotal_bytes - node_memory_MemFree_bytes"` |  |
| prometheusrule.groups[0].rules[0].record | string | `"node_memory_UsageTotal_bytes"` |  |
| prometheusrule.prometheus.labels.app | string | `"kube-prometheus-stack"` |  |
| prometheusrule.prometheus.labels.release | string | `"prometheus"` |  |
| prometheusrule.prometheus.namespace | string | `"default"` |  |
| resources | object | `{}` |  |
| securityContext | object | `{}` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| tolerations | list | `[]` |  |
| workload | string | `"Deployment"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
