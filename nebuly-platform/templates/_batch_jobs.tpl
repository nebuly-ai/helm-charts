{{- define "batchJobs.commonEnv" -}}
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
- name: PROCESS_LAST_N_HOURS
  value: {{ .Values.primaryProcessing.numHoursProcessed | quote }}

# Feature Flags
- name: MODEL_ISSUE_PROCESSING_VERSION
  value: "v2"
- name: TOPIC_AND_ACTION_PROCESSING_VERSION
  value: {{ .Values.ingestionWorker.settings.topicsAndActionsVersion | quote }}

# Model Suggestions Settings
- name: MODEL_SUGGESTION_LOCAL_MODEL_NAME
  value: {{ .Values.aiModels.modelIssuesClassifier.name | quote }}
- name: MODEL_SUGGESTION_LOCAL_MODEL_VERSION
  value: {{ .Values.aiModels.modelIssuesClassifier.version | quote }}

# Topic Settings
- name: TOPIC_LOCAL_MODEL_NAME
  value: {{ .Values.aiModels.modelTopicClassifier.name | quote }}
- name: TOPIC_LOCAL_MODEL_VERSION
  value: {{ .Values.aiModels.modelTopicClassifier.version | quote }}

# Action Settings
- name: ACTION_LOCAL_MODEL_NAME
  value: {{ .Values.aiModels.modelActionClassifier.name | quote }}
- name: ACTION_LOCAL_MODEL_VERSION
  value: {{ .Values.aiModels.modelActionClassifier.version | quote }}


# OpenAI
- name: OPENAI_PROVIDER
  value: {{ .Values.openAi.provider | quote }}
- name: AZURE_OPENAI_API_VERSION
  value: "{{ .Values.openAi.apiVersion }}"
- name: AZURE_OPENAI_ENDPOINT
  value: "{{ .Values.openAi.endpoint }}"
- name: OPENAI_DEPLOYMENT_FRUSTRATION
  value: "{{ .Values.openAi.gpt4oDeployment }}"
- name: OPENAI_DEPLOYMENT_GPT4O
  value: {{ .Values.openAi.gpt4oDeployment | quote }}
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

# Models
- name: MODEL_PROVIDER
  value: {{ .Values.aiModels.registry | quote }}
- name: MODELS_CACHE_DIR
  value: "/var/cache/nebuly"
- name: SENTENCE_TRANSFORMERS_HOME
  value: "/tmp/hf"
- name: HF_HOME
  value: "/tmp/hf"
{{- end -}}