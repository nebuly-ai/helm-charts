{{- define "ingestionWorker.commonEnv" -}}
# Misc
- name: ENV
  value: "prod"
- name: DEVELOPMENT_MODE
  value: "false"
- name: TOUCH_EVERY_SECONDS
  value: "10"
- name: USE_BACKEND_FOR_CONFIG
  value: "true"
{{- if .Values.ingestionWorker.healthCheckPath }}
- name: HEALTH_CHECK_PATH
  value: "{{ .Values.ingestionWorker.healthCheckPath }}"
{{- end }}
# Workers
- name: NUMBER_OF_WORKERS_INTERACTIONS
  value: "{{ .Values.ingestionWorker.numWorkersInteractions }}"
- name: NUMBER_OF_WORKERS_FEEDBACK_ACTIONS
  value: "{{ .Values.ingestionWorker.numWorkersFeedbackActions }}"
# Misc (TODO: remove)
- name: TENANT
  value: {{ include "telemetry.tenant" . | quote }}
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
- name: "POSTGRES_STATEMENT_TIMEOUT_SECONDS"
  value: {{ .Values.ingestionWorker.statementTimeoutSeconds | quote }}
# Kafka Settings
{{ include "kafka.commonEnv" . }}
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
# Platform services
- name: "TENANT_REGISTRY_URL"
  value: {{ include "authService.url" . }}
- name: BACKEND_URL
  value: {{ include "backend.url" . }}
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
# Tasks
- name: TRACE_INTERACTION_TASK
  value: {{ .Values.ingestionWorker.settings.tasks.traceInteraction | quote }}
- name: FEEDBACK_ACTION_TASK
  value: {{ .Values.ingestionWorker.settings.tasks.feedbackAction | quote }}
- name: INTERACTION_TASK
  value: {{ .Values.ingestionWorker.settings.tasks.interaction | quote }}
- name: TAGS_TASK
  value: {{ .Values.ingestionWorker.settings.tasks.tags | quote }}
# PII Removal
- name: LANGUAGE_DETECTION_MODEL_NAME
  value: {{ .Values.aiModels.modelLanguageDetection.name | quote }}
- name: LANGUAGE_DETECTION_MODEL_VERSION
  value: {{ .Values.aiModels.modelLanguageDetection.version | quote }}
- name: PII_ENABLE_LANGUAGE_DETECTION
  value: {{ .Values.ingestionWorker.settings.enablePiiLanguageDetection | quote }}
- name: PII_DENY_LIST
  value: {{ .Values.ingestionWorker.settings.piiDenyList | toJson | quote }}
# AI Models pulling
{{ include "aiModels.env" . }}
{{- with .Values.ingestionWorker.env }}
{{ toYaml . }}
{{- end }}
{{- end -}}
