apiVersion: v1
data:
  cwagentconfig.json: |
    {
      "agent": {
        "region": "{{ .Values.config.clusterRegion }}"
      },
      "logs": {
        "metrics_collected": {
          "kubernetes": {
            "cluster_name": "{{ .Values.config.clusterName }}",
            "metrics_collection_interval": {{ .Values.config.collectionInterval }},
            "tag_service": {{ .Values.config.tagService }},
            "disable_metric_extraction": true
          }
        },
        "force_flush_interval": 5
      }
    }
kind: ConfigMap
metadata:
  name: cwagentconfig
  namespace: {{ .Release.Namespace }}
