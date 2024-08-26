{{- define "lionLinguist.commonEnv" -}}
# OTEL
- name: OTEL_ENABLED
  value: {{ .Values.otel.enabled | quote }}
- name: OTEL_EXPORTER_OTLP_TRACES_ENDPOINT
  value: {{ .Values.otel.exporterOtlpTracesEndpoint | quote }}
- name: OTEL_EXPORTER_OTLP_METRICS_ENDPOINT
  value: {{ .Values.otel.exporterOtlpMetricsEndpoint | quote }}
- name: OTEL_METRICS_EXPORTER
  value: "otlp"
- name: OTEL_SERVICE_NAME
  value: "lion-linguist"
# Sentry
- name: SENTRY_ENABLED
  value: {{ .Values.lionLinguist.sentry.enabled | quote }}
- name: SENTRY_ENVIRONMENT
  value: {{ .Values.lionLinguist.sentry.environment | quote }}
- name: SENTRY_DSN
  value: {{ .Values.lionLinguist.sentry.dsn | quote }}
- name: SENTRY_TRACES_SAMPLE_RATE
  value: {{ .Values.lionLinguist.sentry.tracesSampleRate | quote }}
- name: SENTRY_PROFILES_SAMPLE_RATE
  value: {{ .Values.lionLinguist.sentry.profilesSampleRate | quote }}
# Misc
- name: "ENV"
  value: "prod"
- name: "SERVER_PORT"
  value: "8080"
- name: "PROJECT_NAME"
  value: "Lion Linguist"
- name: "DEVELOPMENT_MODE"
  value: "false"
- name: "MAX_CONCURRENT_REQUESTS"
  value: {{ .Values.lionLinguist.maxConcurrentRequests | quote }}
# Models
- name: "MODEL_PROVIDER"
  value: {{ .Values.aiModels.registry | quote }}
- name: MODELS_CACHE_DIR
  value: "/var/cache"
- name: EMBEDDING_WARNING_MODEL_NAME
  value: {{ .Values.aiModels.modelEmbeddingWarnings.name | quote }}
- name: EMBEDDING_WARNING_MODEL_VERSION
  value: {{ .Values.aiModels.modelEmbeddingWarnings.version | quote }}
- name: EMBEDDING_INTENT_MODEL_NAME
  value: {{ .Values.aiModels.modelEmbeddingIntents.name | quote }}
- name: EMBEDDING_INTENT_MODEL_VERSION
  value: {{ .Values.aiModels.modelEmbeddingIntents.version | quote }}
- name: EMBEDDING_TOPIC_MODEL_NAME
  value: {{ .Values.aiModels.modelEmbeddingTopic.name | quote }}
- name: EMBEDDING_TOPIC_MODEL_VERSION
  value: {{ .Values.aiModels.modelEmbeddingTopic.version | quote }}
# HF Env vars
- name: SENTENCE_TRANSFORMERS_HOME
  value: "/tmp/hf"
- name: HF_HOME
  value: "/tmp/hf"
{{- if eq .Values.aiModels.registry  "azure_ml" }}
{{ include "aiModels.azureml.env" . }}
{{- end }}
{{- if eq .Values.aiModels.registry  "azure_storage" }}
{{ include "aiModels.azure_storage.env" . }}
{{- end }}
{{- if eq .Values.aiModels.registry  "aws_s3" }}
{{ include "aiModels.aws.env" . }}
{{- end }}
{{- end }}