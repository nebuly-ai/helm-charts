{{- define "secondaryProcessing.modelSuggestions.schedule" -}}
{{ (default .Values.secondaryProcessing.schedule .Values.secondaryProcessing.modelSuggestions.schedule)  | quote }}
{{- end -}}

{{- define "secondaryProcessing.topicsAndActions.schedule" -}}
{{ (default .Values.secondaryProcessing.schedule .Values.secondaryProcessing.topicsAndActions.schedule)  | quote }}
{{- end -}}

{{- define "batchJobs.commonEnv" -}}


# Enrich interaction Model
- name: MODEL_NAME
  value: {{ .Values.aiModels.modelInferenceInteractions.name | quote }}
- name: MODEL_VERSION
  value: {{ .Values.aiModels.modelInferenceInteractions.version | quote }}

# Topic Model
- name: TOPIC_LOCAL_MODEL_NAME
  value: {{ .Values.aiModels.modelTopicClassifier.name | quote }}
- name: TOPIC_LOCAL_MODEL_VERSION
  value: {{ .Values.aiModels.modelTopicClassifier.version | quote }}

# Action Model
- name: ACTION_LOCAL_MODEL_NAME
  value: {{ .Values.aiModels.modelActionClassifier.name | quote }}
- name: ACTION_LOCAL_MODEL_VERSION
  value: {{ .Values.aiModels.modelActionClassifier.version | quote }}

# Jobs Settings
- name: ENABLE_DB_CACHE
  value: {{ .Value.ingestionWorker.settings.enableDbCache}}
- name: ENTITIES_BATCH_SIZE
  value: {{ .Value.ingestionWorker.settings.entitiesBatchSize}}
- name: ENRICH_INTERACTION_BATCH_SIZE
  value: {{ .Value.ingestionWorker.settings.enrichInteractionBatchSize}}


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

# Models
- name: MODEL_PROVIDER
  value: {{ .Values.aiModels.registry | quote }}
- name: MODELS_CACHE_DIR
  value: "/var/cache/nebuly"
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
{{- end -}}