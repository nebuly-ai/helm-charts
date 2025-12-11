{{- define "batchJobs.commonEnv" -}}
# Enrich interaction Model
- name: MODEL_NAME
  value: {{ .Values.aiModels.modelInferenceInteractions.name | quote }}
- name: MODEL_VERSION
  value: {{ .Values.aiModels.modelInferenceInteractions.version | quote }}

# Embedding model
- name: EMBEDDING_LOCAL_MODEL_NAME
  value: {{ .Values.aiModels.modelEmbedding.name | quote }}
- name: EMBEDDING_LOCAL_MODEL_VERSION
  value: {{ .Values.aiModels.modelEmbedding.version | quote }}

# Topic Model
- name: TOPIC_LOCAL_MODEL_NAME
  value: {{ .Values.aiModels.modelTopicClassifier.name | quote }}
- name: TOPIC_LOCAL_MODEL_VERSION
  value: {{ .Values.aiModels.modelTopicClassifier.version | quote }}

# Action Model
- name: ACTION_LOCAL_MODEL_NAME
  value: {{ .Values.aiModels.modelTopicClassifier.name | quote }}
- name: ACTION_LOCAL_MODEL_VERSION
  value: {{ .Values.aiModels.modelTopicClassifier.version | quote }}

# PII Model
- name: ANONYMIZATION_MODEL_NAME
  value: {{ .Values.aiModels.modelPiiRemoval.name | quote }}
- name: ANONYMIZATION_MODEL_VERSION
  value: {{ .Values.aiModels.modelPiiRemoval.version | quote }}

# Jobs Settings
- name: ENABLE_DB_CACHE
  value: {{ .Values.ingestionWorker.settings.enableDbCache | quote }}
- name: ENTITIES_BATCH_SIZE
  value: {{ .Values.ingestionWorker.settings.entitiesBatchSize | quote }}
- name: ENRICH_INTERACTION_BATCH_SIZE
  value: {{ .Values.ingestionWorker.settings.enrichInteractionBatchSize | quote }}
- name: LOOP_JOBS_SLEEP_SECONDS
  value: {{ .Values.fullProcessing.settings.processingDelaySeconds | quote }}


# OpenAI
- name: OPENAI_API_VERSION
  value: "{{ .Values.openAi.apiVersion }}"
- name: OPENAI_BASE_URL
  value: "{{ .Values.openAi.endpoint }}"
- name: OPENAI_DEPLOYMENT_FRUSTRATION
  value: "{{ .Values.openAi.gpt4oDeployment }}"
- name: OPENAI_DEPLOYMENT_GPT4O
  value: {{ .Values.openAi.gpt4oDeployment | quote }}
- name: OPENAI_API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ (tpl .Values.openAi.existingSecret.name . ) | default (include "ingestionWorker.fullname" .) }}
      key: {{ .Values.openAi.existingSecret.apiKey | default "openai-api-key" }}

# Use the conversations table
- name: GEMINI_API_KEY
  value: "empty"
- name: ENABLE_ENRICH_CONVERSATION
  value: "true"
{{- end -}}