{{/*
Common labels
*/}}

{{- define "backend.labels" -}}
app: ecommerce
type: back-end
chart-release: {{ .Release.Name }}
{{- end }}


