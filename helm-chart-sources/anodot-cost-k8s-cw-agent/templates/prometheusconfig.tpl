{{- if .Values.config.enableGpuMonitoring }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheusconfig
  namespace: {{ .Release.Namespace }}
data:
  prometheus.yaml: |
    global:
      scrape_interval: 1m
      scrape_timeout: 10s
    scrape_configs:
      - job_name: 'kubernetes-pod-dcgm-exporter'
        sample_limit: 10000
        metrics_path: /metrics
        kubernetes_sd_configs:
        - role: pod
        relabel_configs:
        - source_labels: [__meta_kubernetes_pod_container_name]
          action: keep
          regex: '^nvidia-dcgm-exporter$'
        - source_labels: [__address__]
          action: replace
          regex: ([^:]+)(?::\d+)?
          replacement: ${1}:9400
          target_label: __address__
        - action: labelmap
          regex: __meta_kubernetes_pod_label_(.+)
        - action: replace
          source_labels:
          - __meta_kubernetes_namespace
          target_label: Namespace
        - source_labels: [__meta_kubernetes_pod_name]
          action: replace
          target_label: pod
        - action: replace
          source_labels:
          - __meta_kubernetes_pod_container_name
          target_label: container_name
        - action: replace
          source_labels:
          - __meta_kubernetes_pod_controller_name
          target_label: pod_controller_name
        - action: replace
          source_labels:
          - __meta_kubernetes_pod_controller_kind
          target_label: pod_controller_kind
        - action: replace
          source_labels:
          - __meta_kubernetes_pod_phase
          target_label: pod_phase
        - action: replace
          source_labels:
          - __meta_kubernetes_pod_node_name
          target_label: NodeName
        - action: replace
          replacement: nvidia-dcgm-exporter
          target_label: Service
        - action: replace
          replacement: {{ .Values.config.clusterName }}
          target_label: ClusterName
{{- end }}

