{{/*
Selector labels
*/}}


{{- define "mongodb.labels" -}}
app: ecommerce
chart-release: {{ .Release.Name }}
tier: mongodb
{{- end }}

