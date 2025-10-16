package-otterscale:
	helm package charts/otterscale --destination docs/

index:
	helm repo index docs/ --url https://raw.githubusercontent.com/otterscale/otterscale-charts/refs/heads/main/docs
