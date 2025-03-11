{{- define "clickhouse.fullname" -}}
{{- printf "%s-%s" .Release.Name "clickhouse" | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "clickhouse.backups.azure.env" -}}
- name: REMOTE_STORAGE
  value: "azblob"
- name: AZBLOB_ACCOUNT_KEY
  valueFrom:
    secretKeyRef:
      name: {{ (tpl .Values.clickhouse.backups.azure.existingSecret.name . ) | default (include "clickhouse.fullname" .) }}
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
- name: GCS_PATH
  value: backup/shard-{shard}
{{- end -}}

{{- define "clickhouse.backups.aws.env" -}}
- name: REMOTE_STORAGE
  value: "s3"
- name: S3_ENDPOINT
  value: {{ .Values.clickhouse.backups.aws.endpointUrl | quote }}
- name: S3_BUCKET
  value: {{ .Values.clickhouse.backups.aws.bucketName | quote }}
- name: S3_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ (tpl .Values.clickhouse.backups.aws.existingSecret.name . ) | default (include "clickhouse.fullname" .) }}
      key: {{ .Values.clickhouse.backups.aws.existingSecret.accessKeyIdKey | default "aws-access-key-id" }}
- name: S3_SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ (tpl .Values.clickhouse.backups.aws.existingSecret.name . ) | default (include "clickhouse.fullname" .) }}
      key: {{ .Values.clickhouse.backups.aws.existingSecret.secretAccessKeyKey | default "aws-secret-access-key" }}
- name: S3_PATH
  value: backup/shard-{shard}
{{- end -}}
