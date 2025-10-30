{{/*
Expand the name of the chart.
*/}}
{{- define "kubevirt-infra.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kubevirt-infra.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kubevirt-infra.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kubevirt-infra.labels" -}}
helm.sh/chart: {{ include "kubevirt-infra.chart" . }}
{{ include "kubevirt-infra.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kubevirt-infra.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kubevirt-infra.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "kubevirt-infra.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "kubevirt-infra.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "kubevirt.registry" -}}
{{- .Values.kubevirt.imageRegistry | default "quay.io/kubevirt" -}}
{{- end -}}

{{- define "kubevirt.tag" -}}
{{- required "kubevirt.version is required" .Values.kubevirt.version -}}
{{- end -}}

{{- define "kubevirt.image" -}}
{{- $name := required "image name required" .name -}}
{{- printf "%s/%s:%s" (include "kubevirt.registry" .ctx) $name (include "kubevirt.tag" .ctx) -}}
{{- end -}}

{{- define "cdi.tag" -}}
{{- required "cdi.version is required" .Values.cdi.version -}}
{{- end -}}

{{- define "cdi.image" -}}
{{- $name := required "image name required" .name -}}
{{- printf "%s/%s:%s" (include "kubevirt.registry" .ctx) $name (include "cdi.tag" .ctx) -}}
{{- end -}}

