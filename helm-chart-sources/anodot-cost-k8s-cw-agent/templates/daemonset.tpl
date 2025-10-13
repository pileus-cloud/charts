apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: {{ include "anodot-cost-cloudwatch-agent.fullname" . }}
  namespace: {{ .Release.Namespace }}
spec:
  selector:
    matchLabels:
      name: {{ include "anodot-cost-cloudwatch-agent.fullname" . }}
  template:
    metadata:
      labels:
        name: {{ include "anodot-cost-cloudwatch-agent.fullname" . }}
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
            {{- toYaml . | nindent 8 }}
        {{- end }}
      containers:
        - name: cloudwatch-agent
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          resources:
          {{- toYaml .Values.resources | nindent 12 }}
          # Please don't change below envs
          env:
            - name: HOST_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.hostIP
            - name: HOST_NAME
              valueFrom:
                fieldRef:
                  fieldPath: spec.nodeName
            - name: K8S_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
            - name: CI_VERSION
              value: "k8s/1.0.1"
          # Please don't change the mountPath
          volumeMounts:
            - name: cwagentconfig
              mountPath: /etc/cwagentconfig
            - name: rootfs
              mountPath: /rootfs
              readOnly: true
            - name: dockersock
              mountPath: /var/run/docker.sock
              readOnly: true
            - name: varlibdocker
              mountPath: /var/lib/docker
              readOnly: true
            - name: containerdsock
              mountPath: /run/containerd/containerd.sock
              readOnly: true
            - name: sys
              mountPath: /sys
              readOnly: true
            - name: devdisk
              mountPath: /dev/disk
              readOnly: true
            {{- if .Values.config.enableGpuMonitoring }}
            - name: prometheusconfig
              mountPath: /etc/prometheusconfig
              readOnly: true
            {{- end }}
      volumes:
        - name: cwagentconfig
          configMap:
            name: cwagentconfig
        {{- if .Values.config.enableGpuMonitoring }}
        - name: prometheusconfig
          configMap:
            name: prometheusconfig
        {{- end }}
        - name: rootfs
          hostPath:
            path: /
        - name: dockersock
          hostPath:
            path: /var/run/docker.sock
        - name: containerdsock
          hostPath:
            path: /run/containerd/containerd.sock
        - name: varlibdocker
          hostPath:
            path: /var/lib/docker
        - name: sys
          hostPath:
            path: /sys
        - name: devdisk
          hostPath:
            path: /dev/disk/
      terminationGracePeriodSeconds: 60
      hostNetwork: {{ .Values.hostNetwork}}
      serviceAccountName: {{ include "anodot-cost-cloudwatch-agent.fullname" . }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- if .Values.priorityClassName }}
      priorityClassName: {{ .Values.priorityClassName | quote }}
      {{- end }}
