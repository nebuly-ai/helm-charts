{{/* Compile all validation warnings into a single message and call fail. */}}
{{- define "chart.validateValues" -}}
{{- $messages := list -}}
{{/* Frontend */}}
{{/*{{- $messages = append $messages (include "chart.validateValues.frontend.rootUrl" .) -}}*/}}
{{- $messages = append $messages (include "chart.validateValues.frontend.backendApiUrl" .) -}}
{{/* Backend */}}
{{- $messages = append $messages (include "chart.validateValues.telemetry" .) -}}
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
{{- if .Values.aiModels.sync.enabled -}}
{{- $messages = append $messages (include "chart.validateValues.aiModels.sync.source.clientId" .) -}}
{{- $messages = append $messages (include "chart.validateValues.aiModels.sync.source.clientSecret" .) -}}
{{- end -}}
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
{{- if not (contains .Values.aiModels.registry "aws_s3 azure_ml azure_storage") -}}
values: aiModels.registry
  `registry` should be one of the following values: aws_s3, azure_ml, azure_storage
{{- end -}}
{{- end -}}
{{- define "chart.validateValues.aiModels.sync.source.clientId" -}}
{{- if and (empty .Values.aiModels.sync.source.clientId) (empty .Values.aiModels.sync.source.existingSecret.clientIdKey) -}}
values: aiModels.sync.source.clientId
  `clientId` is required when not using an existing secret and should be a non-empty string
{{- end -}}
{{- end -}}
{{- define "chart.validateValues.aiModels.sync.source.clientSecret" -}}
{{- if and (empty .Values.aiModels.sync.source.clientSecret) (empty .Values.aiModels.sync.source.existingSecret.clientSecretKey) -}}
values: aiModels.sync.source.clientSecret
  `clientSecret` is required when not using an existing secret and should be a non-empty string
{{- end -}}
{{- end -}}


{{/* Lion Linguist validation. */}}
{{- define "chart.validateValues.lionLinguist.modelsCache" -}}
{{- if empty .Values.lionLinguist.modelsCache.storageClassName -}}
values: lionLinguist.modelsCache.storageClassName
  `storageClassName` is required and should be a non-empty string
{{- end -}}
{{- end -}}

{{/* Backend validation. */}}
{{- define "chart.validateValues.telemetry" -}}
{{- if and (empty .Values.telemetry.apiKey) (.Values.telemetry.enabled)  -}}
values: telemetry.apiKey
  `apiKey` is required when telemetry is enabled and should be a non-empty string.
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