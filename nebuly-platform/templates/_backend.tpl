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
  value: "{{ .Values.analyticDatabase.name }}"
- name: ANALYTICS_SERVER
  value: "{{ .Values.analyticDatabase.server }}"
# Misc (TODO: remove)
- name: TENANT
  value: {{ include "telemetry.tenant" . | quote }}
# OTEL
- name: OTEL_ENABLED
  value: "{{ .Values.otel.enabled }}"
- name: OTEL_EXPORTER_OTLP_TRACES_ENDPOINT
  value: "{{ .Values.otel.exporterOtlpTracesEndpoint }}"
- name: OTEL_EXPORTER_OTLP_METRICS_ENDPOINT
  value: "{{ .Values.otel.exporterOtlpMetricsEndpoint }}"
- name: OTEL_METRICS_EXPORTER
  value: "otlp"
# Old Auth0 stuff, to be removed as soon as we leave Auth0
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
{{- end -}}