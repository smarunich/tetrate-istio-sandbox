# Functions
.DEFAULT_GOAL := help

.PHONY: all 
all: deploy_infra describe ## Deploy the complete demo stack

.PHONY: help
help: Makefile ## Print help
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\n"} \
			/^[.a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36mmake %-30s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

.PHONY: deploy_infra
deploy_infra: deploy_infra_aws deploy_addons ## Deploy an underlaying infrastructure
deploy_infra_%: 
	@/bin/sh -c './make/infra_$*.sh deploy'

.PHONY: deploy_addons
deploy_addons: deploy_addons_load-balancer-controller deploy_addons_fluxcd deploy_addons_external-dns ## Deploy the default addons
deploy_addons_%:
	@/bin/sh -c './make/addons.sh deploy_$*'

.PHONY: deploy_istio
deploy_tetrate: deploy_istio ## Deploy Istio
deploy_istio: 
	@/bin/sh -c './make/istio.sh deploy'

.PHONY: describe
describe: describe_demo ## Describe the complete demo stack
describe_%:
	@/bin/sh -c './make/describe.sh $*'

.PHONY: demo
demo_01-deploy-application: demo_01-deploy-application ## Deploy the demo application
demo_all: demo_01-deploy-application ## Setup all demos
demo_%:
	@/bin/sh -c './make/demo.sh $*'

.PHONY: destroy
destroy: destroy_infra destroy_local ## Destroy the complete demo stack

.PHONY: destroy_addons
destroy_addons: destroy_addons_external-dns ## Destroy the infra-integrated addons
destroy_addons_%:
	@/bin/sh -c './make/addons.sh destroy_$*'

.PHONY: destroy_infra
destroy_infra: destroy_addons destroy_infra_aws ## Destroy the underlaying infrastructure
destroy_infra_%: 
	@/bin/sh -c './make/infra_$*.sh destroy'

.PHONY: destroy_local
destroy_local:  ## Destroy the local Terraform state and cache
	@$(MAKE) destroy_tfstate
	@$(MAKE) destroy_tfcache
	@$(MAKE) destroy_outputs

.PHONY: destroy_tfstate
destroy_tfstate:
	find . -name *tfstate* -exec rm -rf {} +

.PHONY: destroy_tfcache
destroy_tfcache:
	find . -name .terraform -exec rm -rf {} +
	find . -name .terraform.lock.hcl -delete

.PHONY: destroy_outputs
destroy_outputs:
	rm -f outputs/*-kubeconfig.sh outputs/*-jumpbox.sh outputs/*-kubeconfig outputs/*.jwk outputs/*.pem outputs/*-cleanup.sh
	rm -f outputs/terraform_outputs/*.json
