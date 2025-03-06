{{- define "clickhouse.fullName" -}}
{{- printf "%s-%s" .Release.Name "clickhouse" | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "clickhouse.backups.azure.env" -}}
- name: REMOTE_STORAGE
  value: "azblob"
- name: AZBLOB_ACCOUNT_KEY
  valueFrom:
    secretKeyRef:
      name: {{ (tpl .Values.clickhouse.backups.azure.existingSecret.name . ) | default (include "clickhouse.fullName" .) }}
      key: {{ .Values.clickhouse.backups.azure.existingSecret.storageAccountKeyKey | default "azure-storage-account-key" }}
- name: AZBLOB_ACCOUNT_NAME
  value: {{ .Values.clickhouse.backups.azure.storageAccountName | quote }}
- name: AZBLOB_CONTAINER
  value: {{ .Values.clickhouse.backups.azure.storageContainerName | quote }}
- name: AZBLOB_PATH
  value: backup/shard-{shard}
{{- end -}}

{{- define "clickhouse.backups.gcp.env" -}}
- name: REMOTE_STORAGE
  value: "gcs"
- name: GCS_BUCKET
  value: {{ .Values.clickhouse.backups.gcp.bucketName | quote }}
{{- end -}}
