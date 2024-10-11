{{- define "ingestionWorker.commonEnv" -}}
# Misc
- name: ENV
  value: "prod"
- name: DEVELOPMENT_MODE
  value: "false"
- name: TOUCH_EVERY_SECONDS
  value: "10"
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
- name: LION_LINGUIST_URL
  value: "http://{{ include "lionLinguist.fullname" . }}:{{ .Values.backend.service.port }}"
- name: LION_LINGUIST_RETRY_ATTEMPTS
  value: "{{ .Values.ingestionWorker.lionLinguistRetryAttempts }}"
# Azure OpenAI
- name: OPENAI_PROVIDER
  value: {{ .Values.openAi.provider | quote }}
- name: AZURE_OPENAI_API_VERSION
  value: "{{ .Values.openAi.apiVersion }}"
- name: AZURE_OPENAI_ENDPOINT
  value: "{{ .Values.openAi.endpoint }}"
- name: OPENAI_DEPLOYMENT_FRUSTRATION
  value: "{{ .Values.openAi.frustrationDetectionDeployment }}"
- name: OPENAI_DEPLOYMENT_GPT40
  value: {{ .Values.openAi.gpt4oDeployment | quote }}
- name: OPENAI_DEPLOYMENT_GPT40_MINI
  value: {{ .Values.openAi.gpt4oMiniDeployment | quote }}
- name: AZURE_OPENAI_API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ (tpl .Values.openAi.existingSecret.name . ) | default (include "ingestionWorker.fullname" .) }}
      key: {{ .Values.openAi.existingSecret.apiKey | default "azure-openai-api-key" }}
- name: OPENAI_API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ (tpl .Values.openAi.existingSecret.name . ) | default (include "ingestionWorker.fullname" .) }}
      key: {{ .Values.openAi.existingSecret.apiKey | default "azure-openai-api-key" }}
# Thresholds
- name: THRESHOLD_SUBJECT_CLUSTERING
  value: {{ .Values.ingestionWorker.thresholds.subjectClustering | quote }}
- name: THRESHOLD_SUBJECT_MERGE_CLUSTERS
  value: {{ .Values.ingestionWorker.thresholds.subjectMergeClusters | quote }}
- name: THRESHOLD_INTENT_CLUSTERING
  value: {{ .Values.ingestionWorker.thresholds.intentClustering | quote }}
- name: THRESHOLD_INTENT_MERGE_CLUSTERS
  value: {{ .Values.ingestionWorker.thresholds.intentMergeClusters | quote }}

- name: INTENT_BATCH_SIZE
  value: "5000"
- name: THRESHOLD_CLUSTERING_V2
  value: "0.3"
- name: THRESHOLD_MERGE_CLUSTERS_V2
  value: "0.25"

# Sentry
- name: SENTRY_ENABLED
  value: {{ .Values.ingestionWorker.sentry.enabled | quote }}
- name: SENTRY_ENVIRONMENT
  value: {{ .Values.ingestionWorker.sentry.environment | quote }}
- name: SENTRY_DSN
  value: {{ .Values.ingestionWorker.sentry.dsn | quote }}
- name: SENTRY_TRACES_SAMPLE_RATE
  value: {{ .Values.ingestionWorker.sentry.tracesSampleRate | quote }}
- name: SENTRY_PROFILES_SAMPLE_RATE
  value: {{ .Values.ingestionWorker.sentry.profilesSampleRate | quote }}
{{- end -}}
