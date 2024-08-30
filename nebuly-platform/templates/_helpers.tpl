{{/*
*********************************************************************
* Shared
*********************************************************************
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "nebuly-platform.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "nebuly-platform.namespace" -}}
{{- if .Values.namespaceOverride }}
{{- .Values.namespaceOverride }}
{{- else }}
{{- .Release.Namespace }}
{{- end }}
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

{{- define "actionsProcessing.modelsCache.name" -}}
{{- printf "%s-%s" .Release.Name "models-cache" | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
*********************************************************************
* Topics Clustering Job
*********************************************************************
*/}}
{{- define "jobTopicsClustering.labels" -}}
{{- include "nebuly-platform.selectorLabels" . }}
app.kubernetes.io/component: job-topics-clustering
{{- end }}

{{- define "jobTopicsClustering.fullname" -}}
{{- printf "%s-%s" .Release.Name "topics-clustering" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
*********************************************************************
* Suggestions Job
*********************************************************************
*/}}
{{- define "jobSuggestions.labels" -}}
{{- include "nebuly-platform.selectorLabels" . }}
app.kubernetes.io/component: job-suggestions
{{- end }}

{{- define "jobSuggestions.fullname" -}}
{{- printf "%s-%s" .Release.Name "suggestions" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
*********************************************************************
* Actions Processing Clustering Job
*********************************************************************
*/}}
{{- define "jobActionsProcessing.labels" -}}
{{- include "nebuly-platform.selectorLabels" . }}
app.kubernetes.io/component: job-topics-clustering
{{- end }}

{{- define "jobActionsProcessing.fullname" -}}
{{- printf "%s-%s" .Release.Name "actions-processing" | trunc 63 | trimSuffix "-" }}
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


