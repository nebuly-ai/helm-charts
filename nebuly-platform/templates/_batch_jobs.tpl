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
- name: ENABLE_SUB_TOPIC
  value: {{ .Values.ingestionWorker.settings.enableSubTopic | quote }}
- name: TOPIC_USE_ONLY_CUSTOM
  value: {{ .Values.ingestionWorker.settings.topicUseOnlyCustom | quote }}
- name: SUB_TOPIC_USE_ONLY_CUSTOM
  value: {{ .Values.ingestionWorker.settings.subTopicUseOnlyCustom | quote }}
- name: ENABLE_FULL_INTENTS
  value: "false"

# Model Suggestions Settings
- name: MODEL_SUGGESTION_LOCAL_MODEL_NAME
  value: {{ .Values.aiModels.modelIssuesClassifier.name | quote }}
- name: MODEL_SUGGESTION_LOCAL_MODEL_VERSION
  value: {{ .Values.aiModels.modelIssuesClassifier.version | quote }}
- name: MODEL_SUGGESTION_CLASSIFIER_KIND
  value: "local_model_majority_vote"
- name: MODEL_SUGGESTION_VARIABLE_CLASSIFIER
  value: "false"


# Model Issue sub category Settings
- name: MODEL_ISSUE_SUB_CATEGORY_LOCAL_MODEL_NAME
  value: {{ .Values.aiModels.modelIssuesClassifier.name | quote }}
- name: MODEL_ISSUE_SUB_CATEGORY_LOCAL_MODEL_VERSION
  value: {{ .Values.aiModels.modelIssuesClassifier.version | quote }}
- name: MODEL_ISSUE_SUB_CATEGORY_CLASSIFIER_KIND
  value: "local_model_majority_vote"
- name: MODEL_ISSUE_SUB_CATEGORY_VARIABLE_CLASSIFIER
  value: "false"


# Topic Settings
- name: TOPIC_LOCAL_MODEL_NAME
  value: {{ .Values.aiModels.modelTopicClassifier.name | quote }}
- name: TOPIC_LOCAL_MODEL_VERSION
  value: {{ .Values.aiModels.modelTopicClassifier.version | quote }}
- name: SUB_TOPIC_LOCAL_MODEL_VERSION
  value: {{ .Values.aiModels.modelTopicClassifier.version | quote }}
- name: TOPIC_CLASSIFIER_KIND
  value: "local_model_majority_vote"
- name: TOPIC_VARIABLE_CLASSIFIER
  value: "false"


# Sub Topic Settings
- name: SUB_TOPIC_LOCAL_MODEL_NAME
  value: {{ .Values.aiModels.modelTopicClassifier.name | quote }}
- name: SUB_TOPIC_LOCAL_MODEL_VERSION
  value: {{ .Values.aiModels.modelTopicClassifier.version | quote }}
- name: SUB_TOPIC_CLASSIFIER_KIND
  value: "local_model_majority_vote"
- name: SUB_TOPIC_VARIABLE_CLASSIFIER
  value: "false"


# Action Settings
- name: ACTION_LOCAL_MODEL_NAME
  value: {{ .Values.aiModels.modelActionClassifier.name | quote }}
- name: ACTION_LOCAL_MODEL_VERSION
  value: {{ .Values.aiModels.modelActionClassifier.version | quote }}
- name: ACTION_CLASSIFIER_KIND
  value: "local_model_majority_vote"
- name: ACTION_VARIABLE_CLASSIFIER
  value: "false"


# Intent Settings
- name: INTENT_LOCAL_MODEL_NAME
  value: {{ .Values.aiModels.modelIntentClassifier.name | quote }}
- name: INTENT_LOCAL_MODEL_VERSION
  value: {{ .Values.aiModels.modelIntentClassifier.version | quote }}
- name: INTENT_CLASSIFIER_KIND
  value: "local_model_majority_vote"


# Sub Intent Settings
- name: SUB_INTENT_LOCAL_MODEL_NAME
  value: {{ .Values.aiModels.modelIntentClassifier.name | quote }}
- name: SUB_INTENT_LOCAL_MODEL_VERSION
  value: {{ .Values.aiModels.modelIntentClassifier.version | quote }}
- name: SUB_INTENT_CLASSIFIER_KIND
  value: "local_model_majority_vote"


# Sub Sub Intent Settings
- name: SUB_SUB_INTENT_LOCAL_MODEL_NAME
  value: {{ .Values.aiModels.modelIntentClassifier.name | quote }}
- name: SUB_SUB_INTENT_LOCAL_MODEL_VERSION
  value: {{ .Values.aiModels.modelIntentClassifier.version | quote }}
- name: SUB_SUB_INTENT_CLASSIFIER_KIND
  value: "local_model_majority_vote"


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