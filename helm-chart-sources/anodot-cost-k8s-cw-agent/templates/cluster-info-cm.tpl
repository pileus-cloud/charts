apiVersion: v1
data:
  cluster.name: {{ .Values.config.clusterName }}
  logs.region: {{ .Values.config.clusterRegion }}
kind: ConfigMap
metadata:
  name: cluster-info
  namespace: {{ .Release.Namespace }}