{{- define "kafka.fullname" -}}
{{- default (printf "%s-%s" .Release.Name "kafka") .Values.kafka.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "kafka.user" -}}
nebuly-platform
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

{{- define "kafka.saslGssapiEnv" -}}
- name: "KAFKA_SASL_GSSAPI_SERVICE_NAME"
  value: {{ .Values.kafka.saslGssapiServiceName | quote }}
- name: "KAFKA_SASL_GSSAPI_PRINCIPAL"
  value: {{ .Values.kafka.saslGssapiKerberosPrincipal | quote }}
- name: "KRB5_CONFIG"
  value: /etc/krb5.conf
{{- end -}}

{{- define "kafka.saslMechanism" -}}
{{- if .Values.kafka.external -}}
{{ .Values.kafka.saslMechanism }}
{{- else -}}
SCRAM-SHA-512
{{- end -}}
{{- end -}}
