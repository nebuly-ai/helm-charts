{{- define "lionLinguist.commonEnv" -}}
# Models
- name: "MODEL_PROVIDER"
  value: {{ .Values.aiModels.registry | quote }}
- name: MODELS_CACHE_DIR
  value: "/var/cache/nebuly"
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
{{- if eq .Values.aiModels.registry  "gcp_bucket" }}
{{ include "aiModels.gcp.env" . }}
{{- end }}
{{- end }}