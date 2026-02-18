{{- define "backend.commonEnv" -}}
# Database
- name: "MULTI_TENANCY_MODE"
  value: {{ .Values.backend.settings.multiTenancyMode | quote }}
- name: "ANALYTICS_USER"
  valueFrom:
    secretKeyRef:
      name: {{ (tpl .Values.analyticDatabase.existingSecret.name . ) | default (include "backend.fullname" .) }}
      key: {{ .Values.analyticDatabase.existingSecret.userKey | default "analytic-database-user" }}
- name: "ANALYTICS_PASSWORD"
  valueFrom:
    secretKeyRef:
      name: {{ (tpl .Values.analyticDatabase.existingSecret.name . ) | default (include "backend.fullname" .) }}
      key: {{ .Values.analyticDatabase.existingSecret.passwordKey | default "analytic-database-password" }}
- name: ANALYTICS_DB
  value: {{ .Values.analyticDatabase.name | quote }}
- name: ANALYTICS_SERVER
  value: {{ .Values.analyticDatabase.server | quote}}
- name: ANALYTICS_SCHEMA_NAME
  value: {{ .Values.analyticDatabase.schema | quote}}
{{- if .Values.backend.settings.alembicTable }}
- name: ANALYTICS_ALEMBIC_VERSION_TABLE
  value: {{ .Values.backend.settings.alembicTable | quote }}
{{- end }}
- name: TENANT
  value: {{ include "telemetry.tenant" . | quote }}
# Feature Flags
- name: ENABLE_LLM_ISSUE_HIDING
  value: {{ .Values.frontend.enableLLMIssueHiding | quote }}
- name: PERFORMANCE_MODE
  value: {{ .Values.frontend.enableHighPerformanceMode | quote }}
- name: ENABLE_LLM_PII_REMOVAL
  value: {{ .Values.ingestionWorker.settings.enablePiiLlm | quote }}
- name: PII_MASK_TENANTS
  value: {{ .Values.ingestionWorker.settings.piiEnabledTenants | toJson | quote }}
- name: ENABLE_USER_ANONYMIZATION
  value: {{ .Values.backend.settings.enableUserAnonymization | quote }}
- name: USER_ANONYMIZATION_KEY
  value: {{ .Values.backend.settings.userAnonymizationKey | quote }}
- name: SCRIPT_PROJECT_IDS
  value: {{ .Values.backend.settings.scriptProjectIds | toJson | quote }}
# Interactions details access control
- name: INTERACTIONS_DETAILS_ACCESS_CONTROL_ENABLED
  value: {{ .Values.interactionsAccessControl.enabled | quote }}
- name: INTERACTIONS_DETAILS_ACCESS_CONTROL_ROLES
  value: '{{ .Values.interactionsAccessControl.redactedRoles | toJson }}'
# OTEL
- name: OTEL_ENABLED
  value: "{{ .Values.otel.enabled }}"
- name: OTEL_EXPORTER_OTLP_TRACES_ENDPOINT
  value: "{{ .Values.otel.exporterOtlpTracesEndpoint }}"
- name: OTEL_EXPORTER_OTLP_METRICS_ENDPOINT
  value: "{{ .Values.otel.exporterOtlpMetricsEndpoint }}"
- name: OTEL_METRICS_EXPORTER
  value: "otlp"
# Auth0 stuff
- name: AUTH0_ENABLED
  value: "false"
- name: OAUTH_CLIENT_ID
  value: ""
- name: OAUTH_CLIENT_SECRET
  value: ""
- name: OAUTH_DOMAIN
  value: ""
- name: OAUTH_AUDIENCE
  value: ""
- name: AUTH0_JWKS_URL
  value: ""
- name: AUTH0_DATABASE_CONNECTION
  value: ""
# Oauth
- name: OAUTH_JWKS_URL
  value: "http://{{ include "authService.fullname" . }}:{{ .Values.auth.service.port }}/auth/well-known/jwk.json"
# Internal services
- name: "TENANT_REGISTRY_URL"
  value: {{ include "authService.url" . }}
# Sentry
- name: SENTRY_ENABLED
  value: {{ .Values.backend.sentry.enabled | quote }}
- name: SENTRY_ENVIRONMENT
  value: {{ .Values.backend.sentry.environment | quote }}
- name: SENTRY_DSN
  value: {{ .Values.backend.sentry.dsn | quote }}
- name: SENTRY_TRACES_SAMPLE_RATE
  value: {{ .Values.backend.sentry.tracesSampleRate | quote }}
- name: SENTRY_PROFILES_SAMPLE_RATE
  value: {{ .Values.backend.sentry.profilesSampleRate | quote }}
# Mixpanel
- name: MIXPANEL_ENABLED
  value: {{ .Values.telemetry.enabled | quote }}
- name: MIXPANEL_MODE
  value: "proxy"
- name: MIXPANEL_PROXY_URL
  value: "https://tunnel.monitor.nebuly.com/mixpanel"
- name: MIXPANEL_USERNAME
  value: {{ .Values.telemetry.tenant | quote }}
- name: MIXPANEL_PASSWORD
  value: {{ .Values.telemetry.apiKey | quote }}
- name: ANALYTICS_OVERRIDE_TENANT
  value: {{ include "telemetry.tenant" . | quote }}
# OpenAI
- name: OPENAI_BASE_URL
  value: {{ .Values.openAi.endpoint | quote }}
- name: OPENAI_API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ (tpl .Values.openAi.existingSecret.name . ) | default (include "backend.fullname" .) }}
      key: {{ .Values.openAi.existingSecret.apiKey | default "openai-api-key" }}
- name: OPENAI_DEPLOYMENT_TRANSLATION
  value: {{ .Values.openAi.translationDeployment | quote }}
- name: OPENAI_ORGANIZATION
  value: ""
# Misc
- name: ENV
  value: "prod"
- name: SERVER_PORT
  value: "8080"
- name: PROJECT_NAME
  value: "backend"
- name: DEVELOPMENT_MODE
  value: "false"
- name: OPENAPI_URL_ENABLED
  value: "false"
{{- if .Values.backend.rootPath }}
- name: ROOT_PATH
  value: "{{ .Values.backend.rootPath }}"
{{- end }}
{{- if .Values.backend.corsAllowOrigins }}
- name: CORS_ALLOW_ORIGINS
  value: {{ .Values.backend.corsAllowOrigins | toJson | quote }}
{{- end }}
{{- if and .Values.clickhouse.enabled .Values.clickhouse.active }}
- name: CLICKHOUSE_ENABLED
  value: "true"
- name: CLICKHOUSE_SERVER
  value: "clickhouse-{{ include "clickhouse.fullname" $ }}"
- name: CLICKHOUSE_MIGRATION_SERVERS
  value: '[{{ range $i, $e := until (.Values.clickhouse.replicas | int) }}{{ if $i }},{{ end }}"chi-{{ include "clickhouse.fullname" $ }}-default-0-{{ $i }}"{{ end }}]'
- name: CLICKHOUSE_DB
  value: {{ .Values.clickhouse.databaseName | quote }}
- name: CLICKHOUSE_USER
  value: {{ .Values.clickhouse.auth.nebulyUser.username | quote }}
- name: CLICKHOUSE_PASSWORD
  value: {{ .Values.clickhouse.auth.nebulyUser.password | quote }}
- name: CLICKHOUSE_INGESTION_BATCH_SIZE
  value: {{ .Values.clickhouse.ingestionBatchSize | quote }}
{{- end }}
{{- end -}}