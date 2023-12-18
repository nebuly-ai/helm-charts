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
{{/* Backend */}}
{{- $messages = append $messages (include "chart.validateValues.backend.postgresServer" .) -}}
{{- $messages = append $messages (include "chart.validateValues.backend.postgresUser" .) -}}
{{- $messages = append $messages (include "chart.validateValues.backend.postgresPassword" .) -}}
{{- $messages = append $messages (include "chart.validateValues.backend.oauthClientId" .) -}}
{{- $messages = append $messages (include "chart.validateValues.backend.oauthClientSecret" .) -}}
{{- $messages = append $messages (include "chart.validateValues.backend.oauthAudience" .) -}}
{{/* Tenant Registry */}}
{{- $messages = append $messages (include "chart.validateValues.tenantRegistry.postgresServer" .) -}}
{{- $messages = append $messages (include "chart.validateValues.tenantRegistry.postgresUser" .) -}}
{{- $messages = append $messages (include "chart.validateValues.tenantRegistry.postgresPassword" .) -}}
{{/* Analytic DB */}}
{{- $messages = append $messages (include "chart.validateValues.analyticDatabase.server" .) -}}
{{- $messages = append $messages (include "chart.validateValues.analyticDatabase.name" .) -}}
{{- $messages = append $messages (include "chart.validateValues.analyticDatabase.user" .) -}}
{{- $messages = append $messages (include "chart.validateValues.analyticDatabase.password" .) -}}
{{/* Oauth */}}
{{- $messages = append $messages (include "chart.validateValues.oauth.domain" .) -}}
{{- $messages = append $messages (include "chart.validateValues.oauth.jwksUrl" .) -}}
{{/* OpenAI */}}
{{- $messages = append $messages (include "chart.validateValues.openai.apiKey" .) -}}
{{- $messages = append $messages (include "chart.validateValues.openai.organizationId" .) -}}
{{/* Kafka */}}
{{- $messages = append $messages (include "chart.validateValues.kafka.bootstrapServers" .) -}}
{{- $messages = append $messages (include "chart.validateValues.kafka.saslUsername" .) -}}
{{- $messages = append $messages (include "chart.validateValues.kafka.saslPassword" .) -}}

{{- $messages = without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{- printf "\nValues validation:\n%s" $message | fail -}}
{{ fail "hello" }}
{{- end -}}
{{- end -}}

{{/* Backend validation. */}}
{{- define "chart.validateValues.backend.postgresServer" -}}
{{- if empty .Values.backend.postgresServer  -}}
values: backend.postgresServer
  `postgresServer` is required and should be a non-empty string
{{- end -}}
{{- end -}}

{{- define "chart.validateValues.backend.postgresPassword" -}}
{{- if empty .Values.backend.postgresPassword  -}}
values: backend.postgresPassword
  `postgresPassword` is required and should be a non-empty string
{{- end -}}
{{- end -}}

{{- define "chart.validateValues.backend.postgresUser" -}}
{{- if empty .Values.backend.postgresUser  -}}
values: backend.postgresUser
  `postgresUser` is required and should be a non-empty string
{{- end -}}
{{- end -}}

{{- define "chart.validateValues.backend.oauthClientId" -}}
{{- if empty .Values.backend.oauthClientId  -}}
values: backend.oauthClientId
  `oauthClientId` is required and should be a non-empty string
{{- end -}}
{{- end -}}

{{- define "chart.validateValues.backend.oauthClientSecret" -}}
{{- if empty .Values.backend.oauthClientSecret  -}}
values: backend.oauthClientSecret
  `oauthClientSecret` is required and should be a non-empty string
{{- end -}}
{{- end -}}

{{- define "chart.validateValues.backend.oauthAudience" -}}
{{- if empty .Values.backend.oauthAudience  -}}
values: backend.oauthAudience
  `oauthAudience` is required and should be a non-empty string
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

{{/* Oauth Validation. */}}
{{- define "chart.validateValues.oauth.domain" -}}
{{- if empty .Values.oauth.domain  -}}
values: oauth.domain
  `domain` is required and should be a non-empty string
{{- end -}}
{{- end -}}

{{- define "chart.validateValues.oauth.jwksUrl" -}}
{{- if empty .Values.oauth.jwksUrl  -}}
values: oauth.jwksUrl
  `jwksUrl` is required and should be a non-empty string
{{- end -}}
{{- end -}}

{{/* OpenAI Validation. */}}
{{- define "chart.validateValues.openai.organizationId" -}}
{{- if empty .Values.openai.organizationId  -}}
values: oauth.organizationId
  `organizationId` is required and should be a non-empty string
{{- end -}}
{{- end -}}

{{- define "chart.validateValues.openai.apiKey" -}}
{{- if empty .Values.openai.apiKey  -}}
values: oauth.apiKey
  `apiKey` is required and should be a non-empty string
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
{{- if empty .Values.kafka.saslUsername  -}}
values: kafka.saslUsername
  `saslUsername` is required and should be a non-empty string
{{- end -}}
{{- end -}}

{{- define "chart.validateValues.kafka.saslPassword" -}}
{{- if empty .Values.kafka.saslPassword  -}}
values: kafka.saslPassword
  `saslPassword` is required and should be a non-empty string
{{- end -}}
{{- end -}}
