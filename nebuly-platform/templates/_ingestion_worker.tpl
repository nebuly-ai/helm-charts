{{- define "ingestionWorker.commonEnv" -}}
# Misc
- name: ENV
  value: "prod"
- name: DEVELOPMENT_MODE
  value: "false"
- name: TOUCH_EVERY_SECONDS
  value: "10"
# Sentry
- name: SENTRY_ENABLED
  value: "false"
# Workers
- name: NUMBER_OF_WORKERS_ACTIONS
  value: "{{ .Values.ingestionWorker.numWorkersActions }}"
- name: NUMBER_OF_WORKERS_INTERACTIONS
  value: "{{ .Values.ingestionWorker.numWorkersInteractions }}"
- name: NUMBER_OF_WORKERS_FEEDBACK_ACTIONS
  value: "{{ .Values.ingestionWorker.numWorkersFeedbackActions }}"
# OTEL
- name: OTEL_SERVICE_NAME
  value: "nebuly-ingestion-worker"
- name: OTEL_EXPORTER_OTLP_TRACES_ENDPOINT
  value: "{{ .Values.otel.exporterOtlpTracesEndpoint }}"
- name: OTEL_EXPORTER_OTLP_METRICS_ENDPOINT
  value: "{{ .Values.otel.exporterOtlpMetricsEndpoint }}"
- name: OTEL_ENABLED
  value: "{{ .Values.otel.enabled }}"
- name: OTEL_METRICS_EXPORTER
  value: "otlp"
# PostgreSQL
- name: POSTGRES_DB
  value: "{{ .Values.analyticDatabase.name }}"
- name: POSTGRES_SERVER
  value: "{{ .Values.analyticDatabase.server }}"
- name: "POSTGRES_USER"
  valueFrom:
    secretKeyRef:
      name: {{ (tpl .Values.analyticDatabase.existingSecret.name . ) | default (include "ingestionWorker.fullname" .) }}
      key: {{ .Values.analyticDatabase.existingSecret.userKey | default "analytic-database-user" }}
- name: "POSTGRES_PASSWORD"
  valueFrom:
    secretKeyRef:
      name: {{ (tpl .Values.analyticDatabase.existingSecret.name . ) | default (include "ingestionWorker.fullname" .) }}
      key: {{ .Values.analyticDatabase.existingSecret.passwordKey | default "analytic-database-password" }}
# Kafka Settings
- name: KAFKA_SOCKET_KEEPALIVE_ENABLED
  value: "{{ .Values.kafka.socketKeepAliveEnabled }}"
- name: KAFKA_BOOTSTRAP_SERVERS
  value: "{{ .Values.kafka.bootstrapServers }}"
- name: KAFKA_TOPIC_EVENTS_MAIN
  value: "{{ .Values.kafka.topicEventsMain }}"
- name: KAFKA_TOPIC_EVENTS_RETRY_1
  value: "{{ .Values.kafka.topicEventsRetry1 }}"
- name: KAFKA_TOPIC_EVENTS_RETRY_2
  value: "{{ .Values.kafka.topicEventsRetry2 }}"
- name: KAFKA_TOPIC_EVENTS_RETRY_3
  value: "{{ .Values.kafka.topicEventsRetry3 }}"
- name: KAFKA_TOPIC_EVENTS_DLQ
  value: "{{ .Values.kafka.topicEventsDlq }}"
- name: "KAFKA_SASL_PASSWORD"
  valueFrom:
    secretKeyRef:
      name: {{ (tpl .Values.kafka.existingSecret.name . ) | default (include "ingestionWorker.fullname" .) }}
      key: {{ .Values.kafka.existingSecret.saslPasswordKey | default "kafka-sasl-password" }}
- name: "KAFKA_SASL_USERNAME"
  valueFrom:
    secretKeyRef:
      name: {{ (tpl .Values.kafka.existingSecret.name . ) | default (include "ingestionWorker.fullname" .) }}
      key: {{ .Values.kafka.existingSecret.saslUsernameKey | default "kafka-sasl-username" }}
# Platform services
- name: TENANT_REGISTRY_URL
  value: "http://{{ include "tenantRegistry.fullname" . }}:{{ .Values.tenantRegistry.service.port }}"
# AzureML
- name: AZURE_TENANT_ID
  value: "{{ .Values.azureml.tenantId }}"
- name: AZURE_SUBSCRIPTION_ID
  value: "{{ .Values.azureml.subscriptionId }}"
- name: AZUREML_RESOURCE_GROUP
  value: "{{ .Values.azureml.resourceGroup }}"
- name: AZUREML_WORKSPACE
  value: "{{ .Values.azureml.workspace }}"
- name: AZUREML_BATCH_ENDPOINT_NAME
  value: "{{ .Values.azureml.batchEndpoint }}"
# TODO: remove me (temporary until we remove OpenAI env vars)
- name: OPENAI_API_KEY
  value: ""
- name: OPENAI_ORGANIZATION_ID
  value: ""
{{- end -}}