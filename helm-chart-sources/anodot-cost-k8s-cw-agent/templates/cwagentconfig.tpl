apiVersion: v1
data:
  cwagentconfig.json: |
    {
      "agent": {
        "region": "{{ .Values.config.clusterName }}"
      },
      "logs": {
        "metrics_collected": {
          "kubernetes": {
            "cluster_name": "{{ .Values.config.clusterRegion }}",
            "metrics_collection_interval": 60
          }
        },
        "force_flush_interval": 5
      }
    }
kind: ConfigMap
metadata:
  name: cwagentconfig
  namespace: {{ .Release.Namespace }}