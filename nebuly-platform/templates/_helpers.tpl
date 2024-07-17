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
* Categories Warnings Job
*********************************************************************
*/}}
{{- define "jobCategoryWarnings.labels" -}}
{{- include "nebuly-platform.selectorLabels" . }}
app.kubernetes.io/component: job-category-warnings
{{- end }}

{{- define "jobCategoryWarnings.fullname" -}}
{{- printf "%s-%s" .Release.Name "category-warnings" | trunc 63 | trimSuffix "-" }}
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
* Utils functions
*********************************************************************
*/}}

{{/* Compile all validation warnings into a single message and call fail. */}}
{{- define "chart.validateValues" -}}
{{- $messages := list -}}
{{/* Frontend */}}
{{/*{{- $messages = append $messages (include "chart.validateValues.frontend.rootUrl" .) -}}*/}}
{{- $messages = append $messages (include "chart.validateValues.frontend.backendApiUrl" .) -}}
{{/* Auth Service */}}
{{- $messages = append $messages (include "chart.validateValues.auth.postgresServer" .) -}}
{{- $messages = append $messages (include "chart.validateValues.auth.postgresUser" .) -}}
{{- $messages = append $messages (include "chart.validateValues.auth.postgresPassword" .) -}}
{{- $messages = append $messages (include "chart.validateValues.auth.loginModes" .) -}}
{{/* Analytic DB */}}
{{- $messages = append $messages (include "chart.validateValues.analyticDatabase.server" .) -}}
{{- $messages = append $messages (include "chart.validateValues.analyticDatabase.name" .) -}}
{{- $messages = append $messages (include "chart.validateValues.analyticDatabase.user" .) -}}
{{- $messages = append $messages (include "chart.validateValues.analyticDatabase.password" .) -}}
{{/* External Kafka */}}
{{- if .Values.kafka.external -}}
{{- $messages = append $messages (include "chart.validateValues.kafka.bootstrapServers" .) -}}
{{- $messages = append $messages (include "chart.validateValues.kafka.saslUsername" .) -}}
{{- $messages = append $messages (include "chart.validateValues.kafka.saslPassword" .) -}}
{{- end -}}
{{/* Azure OpenAI */}}
{{- if .Values.openAi.enabled -}}
{{- $messages = append $messages (include "chart.validateValues.openAi.endpoint" .) -}}
{{- end -}}
{{/* Ingestion Worker*/}}
{{- $messages = append $messages (include "chart.validateValues.actionsProcessing.modelsCache" .) -}}
{{/* Lion Linguist */}}
{{- $messages = append $messages (include "chart.validateValues.lionLinguist.modelsCache" .) -}}
{{/* AI Models */}}
{{- $messages = append $messages (include "chart.validateValues.aiModels.registry" .) -}}
{{/* Azure ML */}}
{{- if .Values.azureml.enabled -}}
{{- $messages = append $messages (include "chart.validateValues.azureml.endpoint" .) -}}
{{- $messages = append $messages (include "chart.validateValues.azureml.tenantId" .) -}}
{{- $messages = append $messages (include "chart.validateValues.azureml.subscriptionId" .) -}}
{{- $messages = append $messages (include "chart.validateValues.azureml.resourceGroup" .) -}}
{{- $messages = append $messages (include "chart.validateValues.azureml.workspace" .) -}}
{{- end -}}

{{- $messages = without $messages "" -}}
{{- $message := join "\n" $messages -}}


{{- if $message -}}
{{- printf "\nValues validation:\n%s" $message | fail -}}
{{ fail "" }}
{{- end -}}
{{- end -}}

{{/* Auth Service validation. */}}
{{- define "chart.validateValues.auth.postgresServer" -}}
{{- if empty .Values.auth.postgresServer  -}}
values: auth.postgresServer
  `postgresServer` is required and should be a non-empty string
{{- end -}}
{{- end -}}

{{- define "chart.validateValues.auth.loginModes" -}}
{{- if and (not .Values.auth.microsoft.enabled) (contains "microsoft" .Values.auth.loginModes) -}}
values: auth.loginModes
  `loginModes` cannot contain "microsoft" when `microsoftSso` is not enabled
{{- end -}}
{{- end -}}

{{- define "chart.validateValues.auth.postgresPassword" -}}
{{- if and (empty .Values.auth.postgresPassword) (empty .Values.auth.existingSecret.name) -}}
values: auth.postgresPassword
  `postgresPassword` is required when not using an existing secret and should be a non-empty string
{{- end -}}
{{- end -}}

{{- define "chart.validateValues.auth.postgresUser" -}}
{{- if and (empty .Values.auth.postgresUser) (empty .Values.auth.existingSecret.name) -}}
values: auth.postgresUser
  `postgresUser` is required when not using an existing secret and should be a non-empty string
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
{{- if and (empty .Values.analyticDatabase.user) (empty .Values.analyticDatabase.existingSecret.name)  -}}
values: analyticDatabase.user
  `user` is required when not using an existing secret and should be a non-empty string
{{- end -}}
{{- end -}}

{{- define "chart.validateValues.analyticDatabase.password" -}}
{{- if and (empty .Values.analyticDatabase.password) (empty .Values.analyticDatabase.existingSecret.name)  -}}
values: analyticDatabase.password
  `password` is required when not using an existing secret and should be a non-empty string
{{- end -}}
{{- end -}}

{{/* External Kafka Validation. */}}
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

{{/* Azure OpenAI . */}}
{{- define "chart.validateValues.openAi.endpoint" -}}
{{- if empty .Values.openAi.endpoint  -}}
values: openAi.endpoint
  `endpoint` is required and should be a non-empty string
{{- else -}}
{{- if not (regexMatch "^(https?|wss?)://[a-zA-Z0-9-]+(\\.[a-zA-Z0-9-]+)+(:[0-9]+)?(/.*)?$" .Values.openAi.endpoint) -}}
values: openAi.endpoint
  `endpoint` should be a valid URL.
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Frontend validation. */}}
{{/*{{- define "chart.validateValues.frontend.rootUrl" -}}*/}}
{{/*{{- if empty .Values.frontend.rootUrl -}}*/}}
{{/*values: frontend.rootUrl*/}}
{{/*  `rootUrl` is required and should be a non-empty string.*/}}
{{/*{{- else -}}*/}}
{{/*{{- if not (regexMatch "^(https?|wss?)://[a-zA-Z0-9-]+(\\.[a-zA-Z0-9-]+)+(:[0-9]+)?(/.*)?$" .Values.frontend.rootUrl) -}}*/}}
{{/*values: frontend.rootUrl*/}}
{{/*  `rootUrl` should be a valid URL.*/}}
{{/*{{- end -}}*/}}
{{/*{{- end -}}*/}}
{{/*{{- end -}}*/}}

{{- define "chart.validateValues.frontend.backendApiUrl" -}}
{{- if empty .Values.frontend.backendApiUrl -}}
values: frontend.backendApiUrl
  `backendApiUrl` is required and should be a non-empty string.
{{- else -}}
{{- if not (regexMatch "^(https?|wss?)://[a-zA-Z0-9-]+(\\.[a-zA-Z0-9-]+)+(:[0-9]+)?(/.*)?$" .Values.frontend.backendApiUrl) -}}
values: frontend.backendApiUrl
  `backendApiUrl` should be a valid URL.
{{- end -}}
{{- end -}}
{{- end -}}


{{/* Ingestion Worker validation. */}}
{{- define "chart.validateValues.actionsProcessing.modelsCache" -}}
{{- if and (empty .Values.actionsProcessing.modelsCache.storageClassName) (.Values.actionsProcessing.modelsCache.enabled) -}}
values: actionsProcessing.modelsCache.storageClassName
  `storageClassName` is required and should be a non-empty string
{{- end -}}
{{- end -}}


{{/* AI Models validation. */}}
{{- define "chart.validateValues.aiModels.registry" -}}
{{- if not (contains .Values.aiModels.registry "aws_s3 azure_ml") -}}
values: aiModels.registry
  `registry` should be one of the following values: aws_s3, azure_ml
{{- end -}}
{{- end -}}


{{/* Lion Linguist validation. */}}
{{- define "chart.validateValues.lionLinguist.modelsCache" -}}
{{- if empty .Values.lionLinguist.modelsCache.storageClassName -}}
values: lionLinguist.modelsCache.storageClassName
  `storageClassName` is required and should be a non-empty string
{{- end -}}
{{- end -}}



{{/* Azure ML validation. */}}
{{- define "chart.validateValues.azureml.endpoint" -}}
{{- if empty .Values.azureml.batchEndpoint  -}}
values: azureml.endpoint
  `endpoint` is required and should be a non-empty string
{{- end -}}
{{- end -}}

{{- define "chart.validateValues.azureml.tenantId" -}}
{{- if empty .Values.azureml.tenantId  -}}
values: azureml.tenantId
  `tenantId` is required and should be a non-empty string
{{- end -}}
{{- end -}}

{{- define "chart.validateValues.azureml.subscriptionId" -}}
{{- if empty .Values.azureml.subscriptionId  -}}
values: azureml.subscriptionId
  `subscriptionId` is required and should be a non-empty string
{{- end -}}
{{- end -}}

{{- define "chart.validateValues.azureml.resourceGroup" -}}
{{- if empty .Values.azureml.resourceGroup  -}}
values: azureml.resourceGroup
  `resourceGroup` is required and should be a non-empty string
{{- end -}}
{{- end -}}

{{- define "chart.validateValues.azureml.workspace" -}}
{{- if empty .Values.azureml.workspace  -}}
values: azureml.workspace
  `workspace` is required and should be a non-empty string
{{- end -}}
{{- end -}}
