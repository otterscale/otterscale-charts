.PHONY: lint
lint: ## 檢查 Chart 語法
	helm lint .

.PHONY: template
template: ## 渲染 templates 並輸出
	helm template otterscale . --namespace otterscale

.PHONY: template-debug
template-debug: ## 渲染 templates 並啟用 debug
	helm template otterscale . --namespace otterscale --debug

.PHONY: install
install: 
	helm install otterscale . -n otterscale -f values.yaml --create-namespace --wait

.PHONY: upgrade
upgrade:
	helm upgrade otterscale . -n otterscale -f values.yaml --wait

.PHONY: uninstall
uninstall: ## 卸載 Release
	helm uninstall otterscale -n otterscale
