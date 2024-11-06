{{/*
*********************************************************************
* Shared
*********************************************************************
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "nebuly-platform.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "nebuly-platform.namespace" -}}
{{- if .Values.namespaceOverride }}
{{- .Values.namespaceOverride }}
{{- else }}
{{- .Release.Namespace }}
{{- end }}
{{- end }}

{{- define "telemetry.tenant" }}
{{- .Values.telemetry.tenant | default .Release.Name }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "nebuly-platform.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "nebuly-platform.labels" -}}
helm.sh/chart: {{ include "nebuly-platform.chart" . }}
{{ include "nebuly-platform.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "nebuly-platform.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nebuly-platform.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: {{ .Chart.Name }}
{{- end }}

{{/*
Common annotations
*/}}
{{- define "nebuly-platform.annotations" -}}
nebuly.com/release-name: {{ .Release.Name }}
{{- with .Values.annotations }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
*********************************************************************
* Hooks
*********************************************************************
*/}}
{{- define "postUpgrade.refreshRoLabels" -}}
{{- include "nebuly-platform.selectorLabels" . }}
helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
{{- end }}

{{/*
*********************************************************************
* Backend
*********************************************************************
*/}}
{{- define "backend.labels" -}}
{{- include "backend.selectorLabels" . }}
{{- end }}

{{- define "backend.selectorLabels" -}}
{{- include "nebuly-platform.selectorLabels" . }}
app.kubernetes.io/component: nebuly-backend
{{- end }}

{{- define "backend.fullname" -}}
{{- if .Values.backend.fullnameOverride }}
{{- .Values.backend.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name "backend" | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*

*********************************************************************
* Backend Scheduler
*********************************************************************
*/}}
{{- define "backendScheduler.labels" -}}
{{- include "backendScheduler.selectorLabels" . }}
{{- end }}

{{- define "backendScheduler.selectorLabels" -}}
{{- include "nebuly-platform.selectorLabels" . }}
app.kubernetes.io/component: nebuly-backend-scheduler
{{- end }}

{{- define "backendScheduler.fullname" -}}
{{- printf "%s-%s" .Release.Name "backend-scheduler" | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
*********************************************************************
* Lion Linguist
*********************************************************************
*/}}
{{- define "lionLinguist.labels" -}}
{{- include "lionLinguist.selectorLabels" . }}
{{- end }}

{{- define "lionLinguist.selectorLabels" -}}
{{- include "nebuly-platform.selectorLabels" . }}
app.kubernetes.io/component: nebuly-lion-linguist
{{- end }}

{{- define "lionLinguist.fullname" -}}
{{- if .Values.lionLinguist.fullnameOverride }}
{{- .Values.lionLinguist.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name "lion-linguist" | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
*********************************************************************
* Event Ingestion
*********************************************************************
*/}}
{{- define "eventIngestion.labels" -}}
{{- include "eventIngestion.selectorLabels" . }}
{{- end }}

{{- define "eventIngestion.selectorLabels" -}}
{{- include "nebuly-platform.selectorLabels" . }}
app.kubernetes.io/component: nebuly-event-ingestion
{{- end }}

{{- define "eventIngestion.fullname" -}}
{{- if .Values.eventIngestion.fullnameOverride }}
{{- .Values.eventIngestion.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name "event-ingestion" | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
*********************************************************************
* Ingestion Worker
*********************************************************************
*/}}
{{- define "ingestionWorker.labels" -}}
{{- include "ingestionWorker.selectorLabels" . }}
{{- end }}

{{- define "ingestionWorker.selectorLabels" -}}
{{- include "nebuly-platform.selectorLabels" . }}
app.kubernetes.io/component: nebuly-ingestion-worker
{{- end }}

{{- define "ingestionWorker.fullname" -}}
{{- if .Values.ingestionWorker.fullnameOverride }}
{{- .Values.ingestionWorker.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name "ingestion-worker" | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{- define "primaryProcessing.modelsCache.name" -}}
{{- printf "%s-%s" .Release.Name "primary-models-cache" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "primaryProcessing.commonLabels" -}}
platform.nebuly.com/processing-stage: primary
{{- end }}

{{- define "secondaryProcessing.commonLabels" -}}
platform.nebuly.com/processing-stage: secondary
{{- end }}

{{/*
*********************************************************************
* Cronjob Primary - Enrich Interactions
*********************************************************************
*/}}
{{- define "jobPrimaryEnrichInteractions.labels" -}}
{{ include "nebuly-platform.selectorLabels" . }}
{{ include "primaryProcessing.commonLabels" . }}
app.kubernetes.io/component: job-enrich-interactions
{{- end }}

{{- define "jobPrimaryEnrichInteractions.fullname" -}}
{{- printf "%s-%s" .Release.Name "enrich-interactions" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
*********************************************************************
* Cronjob Primary - Process Intents
*********************************************************************
*/}}
{{- define "jobPrimaryProcessIntents.labels" -}}
{{ include "nebuly-platform.selectorLabels" . }}
{{ include "primaryProcessing.commonLabels" . }}
app.kubernetes.io/component: job-process-intents
{{- end }}

{{- define "jobPrimaryProcessIntents.fullname" -}}
{{- printf "%s-%s" .Release.Name "process-intents" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
*********************************************************************
* Cronjob Primary - Process Model Suggestions
*********************************************************************
*/}}
{{- define "jobPrimaryProcessModelSuggestions.labels" -}}
{{ include "nebuly-platform.selectorLabels" . }}
{{ include "primaryProcessing.commonLabels" . }}
app.kubernetes.io/component: job-process-model-suggestions
{{- end }}

{{- define "jobPrimaryProcessModelSuggestions.fullname" -}}
{{- printf "%s-%s" .Release.Name "process-model-suggestions" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
*********************************************************************
* Cronjob Secondary - Process Business Suggestions
*********************************************************************
*/}}
{{- define "jobSecondaryProcessBusinessSuggestions.labels" -}}
{{ include "nebuly-platform.selectorLabels" . }}
{{ include "secondaryProcessing.commonLabels" . }}
app.kubernetes.io/component: job-process-business-suggestions
{{- end }}

{{- define "jobSecondaryProcessBusinessSuggestions.fullname" -}}
{{- printf "%s-%s" .Release.Name "process-business-suggestions" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
*********************************************************************
* Cronjob Secondary - Process Moderation Suggestions
*********************************************************************
*/}}
{{- define "jobSecondaryProcessModerationSuggestions.labels" -}}
{{ include "nebuly-platform.selectorLabels" . }}
{{ include "secondaryProcessing.commonLabels" . }}
app.kubernetes.io/component: job-process-moderation-suggestions
{{- end }}

{{- define "jobSecondaryProcessModerationSuggestions.fullname" -}}
{{- printf "%s-%s" .Release.Name "process-moderation-suggestions" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
*********************************************************************
* Cronjob Secondary - Process Topics and Actions
*********************************************************************
*/}}
{{- define "jobSecondaryProcessTopicsAndActions.labels" -}}
{{ include "nebuly-platform.selectorLabels" . }}
{{ include "secondaryProcessing.commonLabels" . }}
app.kubernetes.io/component: job-process-topics-and-actions
{{- end }}

{{- define "jobSecondaryProcessTopicsAndActions.fullname" -}}
{{- printf "%s-%s" .Release.Name "process-topics-and-actions" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
*********************************************************************
* Models Sync Job
*********************************************************************
*/}}
{{- define "modelsSync.labels" -}}
{{- include "nebuly-platform.selectorLabels" . }}
app.kubernetes.io/component: models-sync
{{- end }}

{{- define "modelsSync.fullname" -}}
{{- printf "%s-%s" .Release.Name "models-sync" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*

*********************************************************************
* Auth Service
*********************************************************************
*/}}
{{- define "authService.labels" -}}
{{- include "authService.selectorLabels" . }}
{{- end }}

{{- define "authService.selectorLabels" -}}
{{- include "nebuly-platform.selectorLabels" . }}
app.kubernetes.io/component: nebuly-auth-service
{{- end }}

{{- define "authService.fullname" -}}
{{- if .Values.auth.fullnameOverride }}
{{- .Values.auth.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name "auth-service" | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
*********************************************************************
* Frontend
*********************************************************************
*/}}
{{- define "frontend.labels" -}}
{{- include "frontend.selectorLabels" . }}
{{- end }}

{{- define "frontend.selectorLabels" -}}
{{- include "nebuly-platform.selectorLabels" . }}
app.kubernetes.io/component: nebuly-frontend
{{- end }}

{{- define "frontend.fullname" -}}
{{- if .Values.frontend.fullnameOverride }}
{{- .Values.frontend.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name "frontend" | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}


{{/*
*********************************************************************
* External Kafka
*********************************************************************
*/}}
{{- define "externalKakfaSecretName" -}}
{{- printf "%s-%s" .Release.Name "external-kafka" | trunc 63 | trimSuffix "-" }}
{{- end }}



{{/*
*********************************************************************
* Feature Flags
*********************************************************************
*/}}
{{- define "featureTranslationsEnabled" -}}
{{- if empty .Values.openAi.translationDeployment -}}
false
{{- else -}}
true
{{- end -}}
{{- end -}}
