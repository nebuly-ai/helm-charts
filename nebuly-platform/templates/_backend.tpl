{{- define "backend.commonEnv" -}}
# Database
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
  value: "http://auth-service/auth/well-known/jwk.json"
# Internal services
- name: TENANT_REGISTRY_URL
  value: "http://{{ include "authService.fullname" . }}:{{ .Values.auth.service.port }}"
# Sentry
- name: SENTRY_ENABLED
  value: "false"
# Mixpanel
- name: MIXPANEL_ENABLED
  value: "false"
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
{{- end -}}