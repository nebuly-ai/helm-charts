{{- define "promtail.config" }}
# Promtail configuration file

server:
  http_listen_port: 9080
  grpc_listen_port: 0

clients:
  - url: https://{{.Values.telemetry.tenant}}:{{.Values.telemetry.apiKey}}@loki.monitor.nebuly.com/loki/api/v1/push
    {{- if .Values.telemetry.proxyUrl }}
    tls_config:
       insecure_skip_verify: true
    proxy_url: {{ .Values.telemetry.proxyUrl | quote }}
    {{- end }}

positions:
  filename: /tmp/positions.yaml
target_config:
  sync_period: 10s
scrape_configs:
  - job_name: pod-logs
    kubernetes_sd_configs:
      - role: pod
    pipeline_stages:
      - cri: {}
    relabel_configs:

      # --------------------------------------------- #
      - action: replace
        target_label: platform_nebuly_com_hosting
        replacement: {{ .Values.telemetry.tenant | quote }}
      - action: replace
        target_label: cluster
        replacement: {{ .Values.telemetry.tenant | quote }}
      # --------------------------------------------- #
      #  Collect only logs from nebuly-platform pods  #
      - source_labels: [__meta_kubernetes_pod_label_app_kubernetes_io_part_of]
        action: keep
        regex: {{ .Chart.Name }}
      # --------------------------------------------- #

      - source_labels:
          - __meta_kubernetes_pod_node_name
        target_label: node_name
      - action: replace
        source_labels: [__meta_kubernetes_pod_label_app_kubernetes_io_name]
        target_label: app_kubernetes_io_name

      - action: replace
        source_labels: [__meta_kubernetes_pod_label_batch_kubernetes_io_job_name]
        target_label: batch_kubernetes_io_job_name

      - action: replace
        source_labels: [__meta_kubernetes_pod_label_app_kubernetes_io_component]
        target_label: app_kubernetes_io_component

      - action: replace
        source_labels: [__meta_kubernetes_pod_label_environment]
        target_label: environment

      - action: replace
        replacement: $1
        separator: /
        source_labels:
          - __meta_kubernetes_namespace
          - __meta_kubernetes_pod_name
        target_label: job
      - action: replace
        source_labels:
          - __meta_kubernetes_namespace
        target_label: namespace
      - action: replace
        source_labels:
          - __meta_kubernetes_pod_name
        target_label: pod
      - action: replace
        source_labels:
          - __meta_kubernetes_pod_container_name
        target_label: container
      - replacement: /var/log/pods/*$1/*.log
        separator: /
        source_labels:
          - __meta_kubernetes_pod_uid
          - __meta_kubernetes_pod_container_name
        target_label: __path__
{{- end }}