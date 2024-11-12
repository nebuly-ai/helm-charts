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

# Job version
- name: MODEL_ISSUE_PROCESSING_VERSION
  value: "v2"
- name: TOPIC_AND_ACTION_PROCESSING_VERSION
  value: "v1"

# Model Suggestions Settings
- name: MODEL_ISSUE_ASSIGNMENT_CHUNK_SIZE
  value: "5000"
- name: MODEL_ISSUE_MAX_TOPICS
  value: "200"
- name: MODEL_ISSUE_MAX_LLM_ISSUES_GENERATION_ITERATIONS
  value: "10"
- name: MODEL_ISSUE_ASYNC_BATCH_SIZE
  value: "40"
- name: MODEL_ISSUE_LOCAL_MODEL_NAME
  value: "model-issues-classifier"
- name: MODEL_ISSUE_LOCAL_MODEL_VERSION
  value: "2"
- name: MODEL_ISSUE_LOCAL_MODEL_TEMPERATURE
  value: "0.5"
- name: MODEL_ISSUE_LOCAL_MODEL_GENERATIONS
  value: "3"
- name: MODEL_ISSUE_CLASSIFIER_KIND
  value: "local_model_majority_vote"
- name: MODEL_ISSUE_VARIABLE_CLASSIFIER
  value: "false"
- name: MODEL_ISSUE_CLASSIFIER_MAX_CANDIDATES_PER_BATCH
  value: "50"

# Topics
- name: TOPIC_FIRST_GENERATION_QUERIES_CHUNK_SIZE
  value: "1000"
- name: TOPIC_ASSIGNMENT_QUERIES_CHUNK_SIZE
  value: "5000"
- name: TOPIC_MIN_PERCENTAGE_SPLIT
  value: "0.35"
- name: TOPIC_MAX_PERCENTAGE_REMOVE
  value: "0.01"
- name: TOPIC_MIN_N_SPLIT
  value: "100"
- name: TOPIC_LOCAL_MODEL_NAME
  value: topics-classifier
- name: TOPIC_LOCAL_MODEL_VERSION
  value: "1"
- name: TOPIC_LOCAL_MODEL_TEMPERATURE
  value: "0.5"
- name: TOPIC_LOCAL_MODEL_GENERATIONS
  value: "3"
- name: TOPIC_CLASSIFIER_KIND
  value: "local_model_majority_vote"
- name: TOPIC_VARIABLE_CLASSIFIER
  value: "false"


# Action settings
- name: ACTION_FIRST_GENERATION_QUERIES_CHUNK_SIZE
  value: "1000"
- name: ACTION_ASSIGNMENT_QUERIES_CHUNK_SIZE
  value: "5000"
- name: ACTION_MIN_PERCENTAGE_SPLIT
  value: "0.3"
- name: ACTION_MAX_PERCENTAGE_REMOVE
  value: "0.01"
- name: ACTION_MIN_N_SPLIT
  value: "100"
- name: ACTION_LOCAL_MODEL_NAME
  value: "intents-classifier"
- name: ACTION_LOCAL_MODEL_VERSION
  value: "1"
- name: ACTION_LOCAL_MODEL_TEMPERATURE
  value: "0.5"
- name: ACTION_LOCAL_MODEL_GENERATIONS
  value: "3"
- name: ACTION_CLASSIFIER_KIND
  value: "local_model_majority_vote"
- name: ACTION_VARIABLE_CLASSIFIER
  value: "false"


# Intent Settings
- name: INTENT_ASSIGNMENT_CHUNK_SIZE
  value: "5000"
- name: INTENT_MAX_TOPICS
  value: "200"
- name: INTENT_LOCAL_MODEL_NAME
  value: "intent-classifier"
- name: INTENT_LOCAL_MODEL_VERSION
  value: "1"
- name: INTENT_LOCAL_MODEL_TEMPERATURE
  value: "0.5"
- name: INTENT_LOCAL_MODEL_GENERATIONS
  value: "3"


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