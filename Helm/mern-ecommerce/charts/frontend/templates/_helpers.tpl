
{{/*
 labels
*/}}


{{- define "frontend.Labels" -}}
app: ecommerce
chart-release: {{ .Release.Name }}
tier: front-end
{{- end }}



