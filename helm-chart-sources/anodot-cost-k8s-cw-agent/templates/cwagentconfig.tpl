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
          }{{- if .Values.config.enableGpuMonitoring }},
          "prometheus": {
            "cluster_name": "{{ .Values.config.clusterName }}",
            "log_group_name": "/aws/containerinsights/{{ .Values.config.clusterName }}/prometheus",
            "prometheus_config_path": "/etc/prometheusconfig/prometheus.yaml",
            "emf_processor": {
              "metric_declaration": [
                {
                  "source_labels": ["Service"],
                  "label_matcher": ".*dcgm.*",
                  "dimensions": [["Service","Namespace","ClusterName","job","pod"]],
                  "metric_selectors": [
                    "^DCGM_FI_DEV_GPU_UTIL$",
                    "^DCGM_FI_DEV_DEC_UTIL$",
                    "^DCGM_FI_DEV_ENC_UTIL$",
                    "^DCGM_FI_DEV_MEM_CLOCK$",
                    "^DCGM_FI_DEV_MEM_COPY_UTIL$",
                    "^DCGM_FI_DEV_POWER_USAGE$",
                    "^DCGM_FI_DEV_ROW_REMAP_FAILURE$",
                    "^DCGM_FI_DEV_SM_CLOCK$",
                    "^DCGM_FI_DEV_XID_ERRORS$",
                    "^DCGM_FI_PROF_DRAM_ACTIVE$",
                    "^DCGM_FI_PROF_GR_ENGINE_ACTIVE$",
                    "^DCGM_FI_PROF_PCIE_RX_BYTES$",
                    "^DCGM_FI_PROF_PCIE_TX_BYTES$",
                    "^DCGM_FI_PROF_PIPE_TENSOR_ACTIVE$"
                  ]
                }
              ]
            }
          }{{- end }}
        },
        "force_flush_interval": 5
      }
    }
kind: ConfigMap
metadata:
  name: cwagentconfig
  namespace: {{ .Release.Namespace }}
