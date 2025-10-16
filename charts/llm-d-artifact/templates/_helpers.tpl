{{/* Sanitize to DNS-1123 label value (<=63):
     regex: ^[A-Za-z0-9]([-A-Za-z0-9_.]*[A-Za-z0-9])?$
     - preserves case (uppercase allowed in label values)
     - replaces illegal chars (incl. /) with '.'
*/}}
{{- define "ma.labelValue" -}}
{{- $raw := . -}}
{{- $s := $raw | regexReplaceAll "[^A-Za-z0-9_.-]" "." -}}
{{- $s = $s | trimPrefix "-" | trimPrefix "." | trimSuffix "-" | trimSuffix "." -}}
{{- $s | trunc 63 | trimSuffix "-" | trimSuffix "." -}}
{{- end -}}

{{/* Sanitize to DNS-1123 name (<=63):
     regex: ^[a-z0-9]([-a-z0-9]*[a-z0-9])?$
     - lowercase required
     - replace illegal chars (incl. / and _) with '-'
*/}}
{{- define "ma.dns1123_63" -}}
{{- $raw := . -}}
{{- $s := $raw | lower | regexReplaceAll "[^a-z0-9.-]" "-" -}}
{{- $s = $s | trimPrefix "-" | trimSuffix "-" -}}
{{- $s | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Convenience wrappers that read from .Values.modelname */}}
{{- define "ma.model.label" -}}
{{ include "ma.labelValue" ( required "values.modelname is required" .Values.modelname ) }}
{{- end -}}

{{- define "ma.model.name" -}}
{{ include "ma.dns1123_63" ( required "values.modelname is required" .Values.modelname ) }}
{{- end -}}