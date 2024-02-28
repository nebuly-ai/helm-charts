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

{{/*
*********************************************************************
* Topics Clustering Job
*********************************************************************
*/}}
{{- define "topicsClustering.labels" -}}
{{- include "topicsClustering.selectorLabels" . }}
{{- end }}

{{- define "topicsClustering.selectorLabels" -}}
{{- include "nebuly-platform.selectorLabels" . }}
app.kubernetes.io/component: job-topics-clustering
{{- end }}

{{- define "topicsClustering.fullname" -}}
{{- printf "%s-%s" .Release.Name "topics-clustering" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
*********************************************************************
* Actions Processing Clustering Job
*********************************************************************
*/}}
{{- define "actionsProcessing.labels" -}}
{{- include "actionsProcessing.selectorLabels" . }}
{{- end }}

{{- define "actionsProcessing.selectorLabels" -}}
{{- include "nebuly-platform.selectorLabels" . }}
app.kubernetes.io/component: job-topics-clustering
{{- end }}

{{- define "actionsProcessing.fullname" -}}
{{- printf "%s-%s" .Release.Name "actions-processing" | trunc 63 | trimSuffix "-" }}
{{- end }}
{{/*

*********************************************************************
* Tenant Registry
*********************************************************************
*/}}
{{- define "tenantRegistry.labels" -}}
{{- include "tenantRegistry.selectorLabels" . }}
{{- end }}

{{- define "tenantRegistry.selectorLabels" -}}
{{- include "nebuly-platform.selectorLabels" . }}
app.kubernetes.io/component: nebuly-tenant-registry
{{- end }}

{{- define "tenantRegistry.fullname" -}}
{{- if .Values.tenantRegistry.fullnameOverride }}
{{- .Values.tenantRegistry.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name "tenant-registry" | trunc 63 | trimSuffix "-" }}
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
* Utils functions
*********************************************************************
*/}}

{{/* Compile all validation warnings into a single message and call fail. */}}
{{- define "chart.validateValues" -}}
{{- $messages := list -}}
{{/* Frontend */}}
{{- $messages = append $messages (include "chart.validateValues.frontend.rootUrl" .) -}}
{{/* Tenant Registry */}}
{{- $messages = append $messages (include "chart.validateValues.tenantRegistry.postgresServer" .) -}}
{{- $messages = append $messages (include "chart.validateValues.tenantRegistry.postgresUser" .) -}}
{{- $messages = append $messages (include "chart.validateValues.tenantRegistry.postgresPassword" .) -}}
{{/* Analytic DB */}}
{{- $messages = append $messages (include "chart.validateValues.analyticDatabase.server" .) -}}
{{- $messages = append $messages (include "chart.validateValues.analyticDatabase.name" .) -}}
{{- $messages = append $messages (include "chart.validateValues.analyticDatabase.user" .) -}}
{{- $messages = append $messages (include "chart.validateValues.analyticDatabase.password" .) -}}
{{/* Kafka */}}
{{- $messages = append $messages (include "chart.validateValues.kafka.bootstrapServers" .) -}}
{{- $messages = append $messages (include "chart.validateValues.kafka.saslUsername" .) -}}
{{- $messages = append $messages (include "chart.validateValues.kafka.saslPassword" .) -}}

{{- $messages = without $messages "" -}}
{{- $message := join "\n" $messages -}}


{{- if $message -}}
{{- printf "\nValues validation:\n%s" $message | fail -}}
{{ fail "" }}
{{- end -}}
{{- end -}}

{{/* Tenant Registry validation. */}}
{{- define "chart.validateValues.tenantRegistry.postgresServer" -}}
{{- if empty .Values.tenantRegistry.postgresServer  -}}
values: tenantRegistry.postgresServer
  `postgresServer` is required and should be a non-empty string
{{- end -}}
{{- end -}}

{{- define "chart.validateValues.tenantRegistry.postgresPassword" -}}
{{- if empty .Values.tenantRegistry.postgresPassword  -}}
values: tenantRegistry.postgresPassword
  `postgresPassword` is required and should be a non-empty string
{{- end -}}
{{- end -}}

{{- define "chart.validateValues.tenantRegistry.postgresUser" -}}
{{- if empty .Values.tenantRegistry.postgresUser  -}}
values: tenantRegistry.postgresUser
  `postgresUser` is required and should be a non-empty string
{{- end -}}
{{- end -}}

{{/* Analytic DB validation. */}}
{{- define "chart.validateValues.analyticDatabase.server" -}}
{{- if empty .Values.analyticDatabase.server  -}}
values: analyticDatabase.server
  `server` is required and should be a non-empty string
{{- end -}}
{{- end -}}
{{- define "chart.validateValues.analyticDatabase.name" -}}
{{- if empty .Values.analyticDatabase.name  -}}
values: analyticDatabase.name
  `name` is required and should be a non-empty string
{{- end -}}
{{- end -}}

{{- define "chart.validateValues.analyticDatabase.user" -}}
{{- if empty .Values.analyticDatabase.user  -}}
values: analyticDatabase.user
  `user` is required and should be a non-empty string
{{- end -}}
{{- end -}}

{{- define "chart.validateValues.analyticDatabase.password" -}}
{{- if empty .Values.analyticDatabase.password  -}}
values: analyticDatabase.password
  `password` is required and should be a non-empty string
{{- end -}}
{{- end -}}


{{/* Kafka Validation. */}}
{{- define "chart.validateValues.kafka.bootstrapServers" -}}
{{- if empty .Values.kafka.bootstrapServers  -}}
values: kafka.bootstrapServers
  `bootstrapServers` is required and should be a non-empty string
{{- end -}}
{{- end -}}

{{- define "chart.validateValues.kafka.saslUsername" -}}
{{- if and (empty .Values.kafka.saslUsername) (empty .Values.kafka.existingSecret.name) -}}
values: kafka.saslUsername
  `saslUsername` is required when not using an existent secret and should be a non-empty string
{{- end -}}
{{- end -}}

{{- define "chart.validateValues.kafka.saslPassword" -}}
{{- if and (empty .Values.kafka.saslPassword) (empty .Values.kafka.existingSecret.name) -}}
values: kafka.saslPassword
  `saslPassword` is required when not using an existing secret and should be a non-empty string
{{- end -}}
{{- end -}}


{{/* Frontend validation. */}}
{{- define "chart.validateValues.frontend.rootUrl" -}}
{{- if empty .Values.frontend.rootUrl -}}
values: frontend.rootUrl
  `rootUrl` is required and should be a non-empty string.
{{- else -}}
{{- if not (regexMatch "^(https?|wss?)://[a-zA-Z0-9-]+(\\.[a-zA-Z0-9-]+)+(:[0-9]+)?(/.*)?$" .Values.frontend.rootUrl) -}}
values: frontend.rootUrl
  `rootUrl` should be a valid URL.
{{- end -}}
{{- end -}}
{{- end -}}

