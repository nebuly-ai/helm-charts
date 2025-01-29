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
{{- end }}