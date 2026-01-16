{{- define "kafka.fullname" -}}
{{- default (printf "%s-%s" .Release.Name "kafka") .Values.kafka.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "kafka.user" -}}
{{ .Values.kafka.user }}
{{- end -}}

{{- define "kafka.kraft" -}}
{{ .Values.kafka.kraft | default "enabled" }}
{{- end -}}

{{- define "kafka.bootstrapServers" -}}
{{- if .Values.kafka.external -}}
{{ .Values.kafka.bootstrapServers }}
{{- else -}}
{{ include "kafka.fullname" . }}-kafka-bootstrap.{{ .Release.Namespace }}.svc:9092
{{- end -}}
{{- end -}}

{{- define "kafka.saslUsernameEnv" -}}
{{- if .Values.kafka.external -}}
valueFrom:
    secretKeyRef:
        name: {{ (tpl .Values.kafka.existingSecret.name .) | default (include "externalKakfaSecretName" .) }}
        key: {{ .Values.kafka.existingSecret.saslUsernameKey | default "kafka-sasl-username" }}
{{- else -}}
value: {{ include "kafka.user" . | quote }}
{{- end -}}
{{- end -}}

{{- define "kafka.saslPasswordEnv" -}}
{{- if .Values.kafka.external -}}
valueFrom:
    secretKeyRef:
        name: {{ (tpl .Values.kafka.existingSecret.name .) | default (include "externalKakfaSecretName" .) }}
        key: {{ .Values.kafka.existingSecret.saslPasswordKey | default "kafka-sasl-password" }}
{{- else -}}
valueFrom:
    secretKeyRef:
        name: {{ include "kafka.user" . | quote }}
        key: "password"
{{- end -}}
{{- end -}}

{{- define "kafka.saslMechanism" -}}
{{- if .Values.kafka.external -}}
{{ .Values.kafka.saslMechanism }}
{{- else -}}
SCRAM-SHA-512
{{- end -}}
{{- end -}}

{{- define "kafka.commonEnv" -}}
- name: KAFKA_SOCKET_KEEPALIVE_ENABLED
  value: {{ .Values.kafka.socketKeepAliveEnabled | quote }}
- name: KAFKA_BOOTSTRAP_SERVERS
  value: {{ include "kafka.bootstrapServers" . }}
- name: "KAFKA_SASL_MECHANISM"
  value: {{ include "kafka.saslMechanism" . | quote }}
{{- if eq .Values.kafka.saslMechanism "PLAIN" }}
- name: "KAFKA_SASL_PASSWORD"
  {{ include "kafka.saslPasswordEnv" . }}
- name: "KAFKA_SASL_USERNAME"
  {{ include "kafka.saslUsernameEnv" . }}
{{- end }}
{{- if eq .Values.kafka.saslMechanism "GSSAPI" }}
- name: "KAFKA_SASL_GSSAPI_SERVICE_NAME"
  value: {{ .Values.kafka.saslGssapiServiceName | quote }}
- name: "KAFKA_SASL_GSSAPI_PRINCIPAL"
  value: {{ .Values.kafka.saslGssapiKerberosPrincipal | quote }}
- name: "KRB5_CONFIG"
  value: /etc/krb5.conf
- name: "KAFKA_SASL_GSSAPI_KEYTAB"
  value: /etc/krb5.keytab
{{- end }}
{{- if or (not .Values.kafka.external) (.Values.kafka.existingSecret.sslCaCertKey) }}
- name: "KAFKA_SSL_CA_PATH"
  value: "/etc/kafka/ca.crt"
{{- end }}
{{- end -}}