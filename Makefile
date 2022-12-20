HELM:=helm

build-charts:
#	$(HELM) init --client-only
	$(HELM) version --client
#	@$(HELM) plugin install https://github.com/instrumenta/helm-kubeval || echo "Skipping error..."
#	HELM=$(HELM) ./kubeval.sh
	$(HELM) lint helm-chart-sources/*
	$(HELM) package helm-chart-sources/*
	$(HELM) repo index --url https://pileus-cloud.github.io/charts/ --merge index.yaml .