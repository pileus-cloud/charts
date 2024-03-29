# k8s-metrics-collector

![Version: 0.1.2](https://img.shields.io/badge/Version-0.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.3.4](https://img.shields.io/badge/AppVersion-0.3.4-informational?style=flat-square)

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
| environment.ACCOUNT_ID | string | `"<ID of your AWS root account>"` |  |
| environment.CLOUD_PROVIDER | string | `"aws"` |  |
| environment.CLUSTER_NAME | string | `"<name of the cluster the chart is being installed to>"` |  |
| environment.LINKED_ACCOUNT_ID | string | `"<ID of your AWS linked account which owns the cluster>"` |  |
| environment.LOG_TO_CLOUD_WATCH | string | `"true"` |  |
| environment.MONITORING | string | `"none"` |  |
| environment.PROMETHEUS_URL | string | `"http://prometheus-kube-prometheus-prometheus:9090"` |  |
| environment.S3_BUCKET | string | `"prod-prometheus-agent"` |  |
| environmentExternalSecrets.enabled | bool | `false` |  |
| environmentExternalSecrets.name | string | `"anodot-cost-secrets"` |  |
| environmentSecrets.AWS_ACCESS_KEY_ID | string | `"<access key for Anodot AWS>"` |  |
| environmentSecrets.AWS_SECRET_ACCESS_KEY | string | `"<secret access key for Anodot AWS>"` |  |
| environmentVars.type | string | `"env"` |  |
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
| resources | object | `{}` |  |
| securityContext | object | `{}` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| tolerations | list | `[]` |  |
| workload | string | `"CronJob"` | workload type: "Deployment", "CronJob" |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
