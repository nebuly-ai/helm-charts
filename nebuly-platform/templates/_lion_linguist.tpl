{{- define "lionLinguist.commonEnv" -}}
# Models
- name: EMBEDDING_WARNING_MODEL_NAME
  value: {{ .Values.aiModels.modelEmbeddingWarnings.name | quote }}
- name: EMBEDDING_WARNING_MODEL_VERSION
  value: {{ .Values.aiModels.modelEmbeddingWarnings.version | quote }}
- name: EMBEDDING_INTENT_MODEL_NAME
  value: {{ .Values.aiModels.modelEmbeddingIntents.name | quote }}
- name: EMBEDDING_INTENT_MODEL_VERSION
  value: {{ .Values.aiModels.modelEmbeddingIntents.version | quote }}
- name: EMBEDDING_ACTION_MODEL_NAME
  value: {{ .Values.aiModels.modelEmbeddingIntents.name | quote }}
- name: EMBEDDING_ACTION_MODEL_VERSION
  value: {{ .Values.aiModels.modelEmbeddingIntents.version | quote }}
- name: EMBEDDING_TOPIC_MODEL_NAME
  value: {{ .Values.aiModels.modelEmbeddingTopic.name | quote }}
- name: EMBEDDING_TOPIC_MODEL_VERSION
  value: {{ .Values.aiModels.modelEmbeddingTopic.version | quote }}
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