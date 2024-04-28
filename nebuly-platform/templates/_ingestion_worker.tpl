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
  value: {{ include "kafka.bootstrapServers" . }}
- name: KAFKA_TOPIC_EVENTS_MAIN
  value: "{{ .Values.kafka.topicEventsMain.name }}"
- name: KAFKA_TOPIC_EVENTS_RETRY_1
  value: "{{ .Values.kafka.topicEventsRetry1.name }}"
- name: KAFKA_TOPIC_EVENTS_RETRY_2
  value: "{{ .Values.kafka.topicEventsRetry2.name }}"
- name: KAFKA_TOPIC_EVENTS_RETRY_3
  value: "{{ .Values.kafka.topicEventsRetry3.name }}"
- name: KAFKA_TOPIC_EVENTS_DLQ
  value: "{{ .Values.kafka.topicEventsDlq.name }}"
- name: "KAFKA_SASL_MECHANISM"
  value: {{ include "kafka.saslMechanism" . | quote }}
- name: "KAFKA_SASL_PASSWORD"
  {{ include "kafka.saslPasswordEnv" . }}
- name: "KAFKA_SASL_USERNAME"
  {{ include "kafka.saslUsernameEnv" . }}
{{- if not .Values.kafka.external }}
- name: "KAFKA_SSL_CA_PATH"
  value: "/etc/kafka/ca.crt"
{{- end }}
# Platform services
- name: TENANT_REGISTRY_URL
  value: "http://{{ include "authService.fullname" . }}:{{ .Values.auth.service.port }}"
- name: BACKEND_URL
  value: "http://{{ include "backend.fullname" . }}:{{ .Values.backend.service.port }}"
# AzureML
- name: AZURE_TENANT_ID
  value: "{{ .Values.azureml.tenantId }}"
- name: AZURE_SUBSCRIPTION_ID
  value: "{{ .Values.azureml.subscriptionId }}"
- name: "AZURE_CLIENT_ID"
  valueFrom:
    secretKeyRef:
      name: {{ (tpl .Values.azureml.existingSecret.name . ) | default (include "ingestionWorker.fullname" .) }}
      key: {{ .Values.azureml.existingSecret.clientIdKey | default "azure-client-id" }}
- name: "AZURE_CLIENT_SECRET"
  valueFrom:
    secretKeyRef:
      name: {{ (tpl .Values.azureml.existingSecret.name . ) | default (include "ingestionWorker.fullname" .) }}
      key: {{ .Values.azureml.existingSecret.clientSecretKey | default "azure-client-secret" }}
- name: AZUREML_RESOURCE_GROUP
  value: "{{ .Values.azureml.resourceGroup }}"
- name: AZUREML_WORKSPACE
  value: "{{ .Values.azureml.workspace }}"
- name: AZUREML_BATCH_ENDPOINT_NAME
  value: "{{ .Values.azureml.batchEndpoint }}"
- name: AZUREML_DATASET_NAME
  value: "{{ .Values.azureml.datasetName }}"
# Azure OpenAI
- name: AZURE_OPENAI_API_VERSION
  value: "{{ .Values.azureOpenAi.apiVersion }}"
- name: AZURE_OPENAI_ENDPOINT
  value: "{{ .Values.azureOpenAi.endpoint }}"
- name: AZURE_OPENAI_DEPLOYMENT_FRUSTRATION
  value: "{{ .Values.azureOpenAi.frustrationDetectionDeployment }}"
- name: AZURE_OPENAI_DEPLOYMENT_CHAT_COMPLETION
  value: "{{ .Values.azureOpenAi.chatCompletionDeployment }}"
- name: AZURE_OPENAI_DEPLOYMENT_EMBEDDINGS
  value: "{{ .Values.azureOpenAi.textEmbeddingsDeployment }}"
- name: AZURE_OPENAI_API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ (tpl .Values.azureOpenAi.existingSecret.name . ) | default (include "ingestionWorker.fullname" .) }}
      key: {{ .Values.azureOpenAi.existingSecret.apiKey | default "azure-openai-api-key" }}
{{- end -}}