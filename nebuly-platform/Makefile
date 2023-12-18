HELM_CHART_REGISTRY ?= oci://ghcr.io/nebuly-ai/helm-charts

##@ General

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


##@ Build dependencies

## Location to install dependencies to
LOCALBIN ?= $(shell pwd)/bin
$(LOCALBIN):
	mkdir -p $(LOCALBIN)

## Tools binaries
HELM_DOCS ?= $(LOCALBIN)/helm-docs

## Tools versions
HELM_DOCS_VERSION ?= v1.11.3

.PHONY: helm-docs-bin ## Download helm-docs if necessary
helm-docs-bin: $(HELM_DOCS)
$(HELM_DOCS): $(LOCALBIN)
	test -s $(LOCALBIN)/helm-docs || GOBIN=$(LOCALBIN) go install github.com/norwoodj/helm-docs/cmd/helm-docs@$(HELM_DOCS_VERSION)


##@ Helm charts
.PHONY: helm-doc
helm-doc: helm-docs-bin ## Generate Helm charts documentation
	$(HELM_DOCS) --chart-search-root . --document-dependency-values

.PHONY: helm-push
helm-push: ## Push the Helm chart to the Helm repository.
	helm package . --destination /tmp/nebuly
	helm push /tmp/nebuly/*.tgz $(HELM_CHART_REGISTRY)
	rm -rf /tmp/nebuly

