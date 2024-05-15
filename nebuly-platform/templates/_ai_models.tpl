{{- define "aiModels.azureml.env" -}}
- name: AZURE_TENANT_ID
  value: "{{ .Values.aiModels.azureml.tenantId }}"
- name: AZURE_SUBSCRIPTION_ID
  value: "{{ .Values.aiModels.azureml.subscriptionId }}"
- name: "AZURE_CLIENT_ID"
  valueFrom:
    secretKeyRef:
      name: {{ (tpl .Values.aiModels.azureml.existingSecret.name . ) | default (include "lionLinguist.fullname" .) }}
      key: {{ .Values.aiModels.azureml.existingSecret.clientIdKey | default "azure-client-id" }}
- name: "AZURE_CLIENT_SECRET"
  valueFrom:
    secretKeyRef:
      name: {{ (tpl .Values.aiModels.azureml.existingSecret.name . ) | default (include "lionLinguist.fullname" .) }}
      key: {{ .Values.aiModels.azureml.existingSecret.clientSecretKey | default "azure-client-secret" }}
{{- end -}}