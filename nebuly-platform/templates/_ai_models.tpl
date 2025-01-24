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
- name: "AWS_S3_BUCKET_NAME"
  value: {{ .Values.aiModels.aws.bucketName | quote }}
{{- end -}}
{{- define "aiModels.gcp.env" -}}
- name: "GCP_BUCKET_NAME"
  value: {{ .Values.aiModels.gcp.bucketName | quote }}
- name: "GCP_PROJECT_NAME"
  value: {{ .Values.aiModels.gcp.projectName | quote }}
{{- end -}}
