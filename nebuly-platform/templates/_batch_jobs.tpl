{{- define "batchJobs.commonEnv" -}}
# Enrich interaction Model
- name: ENRICH_INTERACTION_MODEL_NAME
  value: {{ .Values.aiModels.modelInferenceInteractions.name | quote }}
- name: ENRICH_INTERACTION_MODEL_VERSION
  value: {{ .Values.aiModels.modelInferenceInteractions.version | quote }}

# Embedding model
- name: EMBEDDING_MODEL_NAME
  value: {{ .Values.aiModels.modelEmbedding.name | quote }}
- name: EMBEDDING_MODEL_VERSION
  value: {{ .Values.aiModels.modelEmbedding.version | quote }}

# Classifier Model
- name: CLASSIFIER_MODEL_NAME
  value: {{ .Values.aiModels.modelTopicClassifier.name | quote }}
- name: CLASSIFIER_MODEL_VERSION
  value: {{ .Values.aiModels.modelTopicClassifier.version | quote }}

# Tier assignment model
- name: TIER_ASSIGNMENT_MODEL_NAME
  value: {{ .Values.aiModels.modelTierAssignment.name | quote }}
- name: TIER_ASSIGNMENT_MODEL_VERSION
  value: {{ .Values.aiModels.modelTierAssignment.version | quote }}

# PII Model
- name: ANONYMIZATION_MODEL_NAME
  value: {{ .Values.aiModels.modelPiiRemoval.name | quote }}
- name: ANONYMIZATION_MODEL_VERSION
  value: {{ .Values.aiModels.modelPiiRemoval.version | quote }}
- name: ANONYMIZATION_REPETITION_PENALTY
  value: "1.0"

# Segmentation models
- name: SEGMENTATION_MODEL_NAME
  value: {{ .Values.aiModels.modelSegmentation.name | quote }}
- name: SEGMENTATION_MODEL_VERSION
  value: {{ .Values.aiModels.modelSegmentation.version | quote }}
- name: ENRICH_SEGMENTATION_MODEL_NAME
  value: {{ .Values.aiModels.modelEnrichSegmentation.name | quote }}
- name: ENRICH_SEGMENTATION_MODEL_VERSION
  value: {{ .Values.aiModels.modelEnrichSegmentation.version | quote }}

# Jobs Settings
- name: AGGREGATES_ENTITIES_BATCH_SIZE
  value: {{ .Values.ingestionWorker.settings.entitiesBatchSize | quote }}
- name: ENRICH_INTERACTION_BATCH_SIZE
  value: {{ .Values.ingestionWorker.settings.enrichInteractionBatchSize | quote }}
- name: AI_PROCESSING_GPU_LOOP_SLEEP_SECONDS
  value: {{ .Values.fullProcessing.settings.processingDelaySeconds | quote }}

# Inference settings
- name: LOCAL_MODEL_MICRO_BATCH_TIMEOUT_SECONDS
  value: {{ .Values.ingestionWorker.settings.vLLMBatchTimeout | quote }}
- name: LOCAL_MODEL_MICRO_BATCH_SIZE
  value: {{ .Values.ingestionWorker.settings.vLLMBatchSize | quote }}

{{- define "primaryProcessing.shmVolumeMount" -}}
{{- if .Values.primaryProcessing.shmSize }}
- name: dshm
  mountPath: /dev/shm
{{- end }}
{{- end -}}

{{- define "primaryProcessing.shmVolume" -}}
{{- if .Values.primaryProcessing.shmSize }}
- name: dshm
  emptyDir:
    medium: Memory
    sizeLimit: {{ .Values.primaryProcessing.shmSize }}
{{- end }}
{{- end -}}