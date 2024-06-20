{{/*
Expand the name of the chart.
*/}}
{{- define "bootstrap.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "bootstrap.namespace" -}}
{{- if .Values.namespaceOverride }}
{{- .Values.namespaceOverride }}
{{- else }}
{{- .Release.Namespace }}
{{- end }}
{{- end }}


{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "bootstrap.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "bootstrap.labels" -}}
helm.sh/chart: {{ include "bootstrap.chart" . }}
{{ include "bootstrap.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "bootstrap.selectorLabels" -}}
app.kubernetes.io/name: {{ include "bootstrap.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: {{ .Chart.Name }}
{{- end }}

{{/*
Common annotations
*/}}
{{- define "bootstrap.annotations" -}}
nebuly.com/release-name: {{ .Release.Name }}
{{- with .Values.annotations }}
{{ toYaml . }}
{{- end }}
{{- end }}


{{/*
*********************************************************************
* Utils functions
*********************************************************************
*/}}

{{/* Compile all validation warnings into a single message and call fail. */}}
{{- define "bootstrap.validateValues" -}}
{{- $messages := list -}}
{{/* Cluster Autoscaler */}}
{{- $messages = append $messages (include "bootstrap.validateValues.clusterAutoscaler.roleArn" .) -}}

{{- $messages = without $messages "" -}}
{{- $message := join "\n" $messages -}}


{{- if $message -}}
{{- printf "\nValues validation:\n%s" $message | fail -}}
{{ fail "" }}
{{- end -}}
{{- end -}}

{{/* Cluster Autoscaler validation. */}}
{{- define "bootstrap.validateValues.clusterAutoscaler.roleArn" -}}
{{- if empty (index .Values "cluster-autoscaler" "rbac" "serviceAccount" "annotations" "eks.amazonaws.com/role-arn")  -}}
values: cluster-autoscaler.rbac.serviceAccount.annotations
  `eks.amazonaws.com/role-arn` is required and should be a non-empty string
{{- end -}}
{{- end -}}

