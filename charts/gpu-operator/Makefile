## Get version from Chart.yaml
HAMI_VERSION := $(shell cat Chart.yaml | grep -w '\- name: hami' -A1 | grep version | head -n 1 | cut -d ':' -f 2 | sed 's/^[[:space:]]*//')
NV_OPERATOR_VERSION := $(shell cat Chart.yaml | grep -w '\- name: gpu-operator' -A1 | grep version | cut -d ':' -f 2 | sed 's/^[[:space:]]*//')

install:
	helm install gpu-operator ./ -n gpu-operator -f values.yaml --create-namespace

upgrade:
	helm upgrade gpu-operator ./ -n gpu-operator -f values.yaml

uninstall:
	helm uninstall gpu-operator -n gpu-operator

dryrun:
	helm install gpu-operator ./ -n gpu-operator -f values.yaml --create-namespace --dry-run --debug

refresh-hami:
	@echo "Download HAMi version $(HAMI_VERSION) from github..."
	@mkdir ./tmp
	@wget -qO- https://github.com/Project-HAMi/HAMi/releases/download/v$(HAMI_VERSION)/hami-$(HAMI_VERSION).tgz | tar -xz -C ./tmp
	
	@FILE=./tmp/hami/templates/device-plugin/daemonsetnvidia.yaml; \
	sed -i '/{{- if .Values.devicePlugin.nvidianodeSelector }}/,/{{- end }}/ s/^/#/' $$FILE; \
	printf '      {{- if .Values.devicePlugin.nodeSelector }}\n      nodeSelector: {{ toYaml .Values.devicePlugin.nodeSelector | nindent 8 }}\n      {{- end }}\n' >> $$FILE
	
	@FILE=./tmp/hami/values.yaml; \
	sed -i '/nvidianodeSelector:/,+1 s/^/#/' $$FILE
	
	@rm -r ./charts/hami; \
	cp -r ./tmp/hami ./charts/hami; \
	rm -r tmp

refresh-nv-operator:
	@echo "Download nvidia gpu-operator version $(NV_OPERATOR_VERSION) from github..."
	@mkdir ./tmp
	@helm repo add nvidia https://helm.ngc.nvidia.com/nvidia > /dev/null; \
	helm repo update > /dev/null; \
	helm pull nvidia/gpu-operator --version $(NV_OPERATOR_VERSION) --untar --untardir ./tmp
	
	@rm -r ./charts/gpu-operator; \
	cp -r ./tmp/gpu-operator ./charts/gpu-operator; \
	rm -r tmp
