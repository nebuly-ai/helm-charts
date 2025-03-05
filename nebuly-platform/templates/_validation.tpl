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
{{- $messages = append $messages (include "chart.validateValues.auth.microsoft" .) -}}
{{- $messages = append $messages (include "chart.validateValues.auth.okta" .) -}}
{{- $messages = append $messages (include "chart.validateValues.auth.addMember" .) -}}
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
{{- $messages = append $messages (include "chart.validateValues.openAi.gpt4oDeployment" .) -}}
{{- end -}}
{{/* Ingestion Worker*/}}
{{- $messages = append $messages (include "chart.validateValues.primaryProcessing.modelsCache" .) -}}
{{/* AI Models */}}
{{- $messages = append $messages (include "chart.validateValues.aiModels.registry" .) -}}
{{- if .Values.aiModels.sync.enabled -}}
{{- $messages = append $messages (include "chart.validateValues.aiModels.sync.source.clientId" .) -}}
{{- $messages = append $messages (include "chart.validateValues.aiModels.sync.source.clientSecret" .) -}}
{{- end -}}
{{/* ClickHouse */}}
{{- if .Values.clickhouse.enabled -}}
{{- $messages = append $messages (include "chart.validateValues.clickhouse.replicas" .) -}}
{{- if .Values.clickhouse.backups.enabled -}}
{{- $messages = append $messages (include "chart.validateValues.clickhouse.backups.remoteStorage" .) -}}
{{- end -}}
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

{{- define "chart.validateValues.auth.microsoft" -}}
{{- if and (not .Values.auth.microsoft.enabled) (contains "microsoft" .Values.auth.loginModes) -}}
values: auth.loginModes
  `loginModes` cannot contain "microsoft" when `auth.microsoft.enabled` is false
{{- end -}}
{{- end -}}

{{- define "chart.validateValues.auth.okta" -}}
{{- if and (not .Values.auth.okta.enabled) (contains "okta" .Values.auth.loginModes) -}}
values: auth.loginModes
  `loginModes` cannot contain "okta" when `auth.okta.enabled` is false
{{- end -}}
{{- end -}}

{{- define "chart.validateValues.auth.addMember" -}}
{{- if and (.Values.auth.addMembersEnabled) (not (contains "password" .Values.auth.loginModes)) -}}
values: auth.addMembersEnabled
  `addMembersEnabled` can't be set to true if `password` is not in `loginModes`
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
{{- define "chart.validateValues.openAi.gpt4oDeployment" -}}
{{- if empty .Values.openAi.gpt4oDeployment  -}}
values: openAi.gpt4oDeployment
  `gpt4oDeployment` is required and should be a non-empty string
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
{{- define "chart.validateValues.primaryProcessing.modelsCache" -}}
{{- if and (empty .Values.primaryProcessing.modelsCache.storageClassName) (.Values.primaryProcessing.modelsCache.enabled) -}}
values: primaryProcessing.modelsCache.storageClassName
  `storageClassName` is required and should be a non-empty string
{{- end -}}
{{- end -}}


{{/* AI Models validation. */}}
{{- define "chart.validateValues.aiModels.registry" -}}
{{- if not (contains .Values.aiModels.registry "aws_s3 azure_ml azure_storage gcp_bucket") -}}
values: aiModels.registry
  `registry` should be one of the following values: aws_s3, azure_ml, azure_storage, gcp_bucket
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


{{/* Backend validation. */}}
{{- define "chart.validateValues.telemetry" -}}
{{- if and (empty .Values.telemetry.apiKey) (.Values.telemetry.enabled)  -}}
values: telemetry.apiKey
  `apiKey` is required when telemetry is enabled and should be a non-empty string.
{{- end -}}
{{- end -}}


{{/* ClickHouse validation. */}}
{{- define "chart.validateValues.clickhouse.replicas" -}}
{{- if and (gt (int .Values.clickhouse.replicas) 1) (not .Values.clickhouse.keeper.enabled) -}}
values: clickhouse.replicas
  `replicas` should be 1 when `clickhouse.keeper.enabled` is false
{{- end -}}
{{- end -}}

{{- define "chart.validateValues.clickhouse.backups.remoteStorage" -}}
{{- if empty .Values.clickhouse.backups.remoteStorage  -}}
values: clickhouse.backups.remoteStorage
  `remoteStorage` is required when backups is enabled, and should be a non-empty string
{{- end -}}
{{- if not (contains .Values.clickhouse.backups.remoteStorage "aws_s3 azure_storage gcp_bucket") -}}
values: clickhouse.backups.remoteStorage
  `remoteStorage` should be one of the following values: aws_s3, azure_storage, gcp_bucket
{{- end -}}
{{- end -}}