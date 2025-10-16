package:
	helm package charts/otterscale --destination docs/
	helm package charts/infra --destination docs/
	helm package charts/llm-d-artifact --destination docs/
	helm package charts/gpu-operator --destination docs/

index:
	helm repo index docs/ --url https://raw.githubusercontent.com/otterscale/otterscale-charts/refs/heads/main/docs
