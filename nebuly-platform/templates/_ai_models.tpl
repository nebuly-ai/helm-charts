{{- define "aiModels.env" -}}
- name: MODEL_PROVIDER
  value: {{ .Values.aiModels.registry | quote }}
- name: MODELS_CACHE_DIR
  value: "/var/cache/nebuly"
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

{{- define "aiModels.azureml.env" -}}
- name: AZURE_TENANT_ID
  value: "{{ .Values.aiModels.azureml.tenantId }}"
- name: AZURE_SUBSCRIPTION_ID
  value: "{{ .Values.aiModels.azureml.subscriptionId }}"
- name: AZUREML_RESOURCE_GROUP
  value: "{{ .Values.aiModels.azureml.resourceGroup }}"
- name: AZUREML_WORKSPACE
  value: "{{ .Values.aiModels.azureml.workspace }}"
- name: "AZURE_CLIENT_ID"
  valueFrom:
    secretKeyRef:
      name: {{ (tpl .Values.aiModels.azureml.existingSecret.name . ) | default (include "modelRegistry.fullname" .) }}
      key: {{ .Values.aiModels.azureml.existingSecret.clientIdKey | default "azure-client-id" }}
- name: "AZURE_CLIENT_SECRET"
  valueFrom:
    secretKeyRef:
      name: {{ (tpl .Values.aiModels.azureml.existingSecret.name . ) | default (include "modelRegistry.fullname" .) }}
      key: {{ .Values.aiModels.azureml.existingSecret.clientSecretKey | default "azure-client-secret" }}
{{- end -}}
{{- define "aiModels.azure_storage.env" -}}
- name: AZURE_STORAGE_ACCOUNT_NAME
  value: "{{ .Values.aiModels.azure.storageAccountName }}"
- name: AZURE_STORAGE_CONTAINER_NAME
  value: "{{ .Values.aiModels.azure.storageContainerName }}"
- name: "AZURE_TENANT_ID"
  value: {{ .Values.aiModels.azure.tenantId | quote }}
- name: "AZURE_CLIENT_ID"
  value: {{ .Values.aiModels.azure.managedIdentityClientId | quote }}
{{- end -}}
{{- define "aiModels.aws.env" -}}
{{- if .Values.aiModels.aws.endpointUrl }}
- name: "AWS_S3_ENDPOINT_URL"
  value: {{ .Values.aiModels.aws.endpointUrl | quote }}
{{- end }}
- name: "AWS_S3_BUCKET_NAME"
  value: {{ .Values.aiModels.aws.bucketName | quote }}
- name: "AWS_ACCESS_KEY_ID"
  valueFrom:
    secretKeyRef:
      name: {{ (tpl .Values.aiModels.aws.existingSecret.name . ) | default (include "modelRegistry.fullname" .) }}
      key: {{ .Values.aiModels.aws.existingSecret.accessKeyIdKey | default "aws-access-key-id" }}
- name: "AWS_SECRET_ACCESS_KEY"
  valueFrom:
    secretKeyRef:
      name: {{ (tpl .Values.aiModels.aws.existingSecret.name . ) | default (include "modelRegistry.fullname" .) }}
      key: {{ .Values.aiModels.aws.existingSecret.secretAccessKeyKey | default "aws-secret-access-key" }}
{{- end -}}
{{- define "aiModels.gcp.env" -}}
- name: "GCP_BUCKET_NAME"
  value: {{ .Values.aiModels.gcp.bucketName | quote }}
- name: "GCP_PROJECT_NAME"
  value: {{ .Values.aiModels.gcp.projectName | quote }}
{{- end -}}
