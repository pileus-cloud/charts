apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "anodot-cost-cloudwatch-agent.fullname" . }}
  namespace: {{ .Release.Namespace }}
{{- with .Values.serviceAccount.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
{{- end }}
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: {{ include "anodot-cost-cloudwatch-agent.fullname" . }}-role-binding
subjects:
  - kind: ServiceAccount
    name: {{ include "anodot-cost-cloudwatch-agent.fullname" . }}
    namespace: {{ .Release.Namespace }}
roleRef:
  kind: ClusterRole
  name: {{ include "anodot-cost-cloudwatch-agent.fullname" . }}-role
  apiGroup: rbac.authorization.k8s.io
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: {{ include "anodot-cost-cloudwatch-agent.fullname" . }}-role
rules:
  - apiGroups: [""]
    resources: ["pods", "nodes", "endpoints"]
    verbs: ["list", "watch"]
  - apiGroups: ["apps"]
    resources: ["replicasets"]
    verbs: ["list", "watch"]
  - apiGroups: ["batch"]
    resources: ["jobs"]
    verbs: ["list", "watch"]
  - apiGroups: [""]
    resources: ["nodes/proxy"]
    verbs: ["get"]
  - apiGroups: [""]
    resources: ["nodes/stats", "configmaps", "events"]
    verbs: ["create"]
  - apiGroups: [""]
    resources: ["configmaps"]
    resourceNames: ["cwagent-clusterleader"]
    verbs: ["get","update"]