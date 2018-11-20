AWS_REGION := ${AWS_REGION}
AWS_ACCESS_KEY_ID := ${AWS_ACCESS_KEY_ID}
AWS_SECRET_ACCESS_KEY := ${AWS_SECRET_ACCESS_KEY}
IMAGE := ${IMAGE}
PORT := ${PORT}
COUNT := ${COUNT}
CPU := ${CPU}
MEMORY := ${MEMORY}

AWS_DIR=$(CURDIR)/terraform/amazon
TERRAFORM_FLAGS :=
AWS_TERRAFORM_FLAGS = -var "region=$(AWS_REGION)" \
		-var "access_key=$(AWS_ACCESS_KEY_ID)" \
		-var "secret_key=$(AWS_SECRET_ACCESS_KEY)" \
		-var "image=$(IMAGE)" \
		-var "port=$(PORT)" \
		-var "count=$(COUNT)" \
		-var "cpu=$(CPU)" \
		-var "memory=$(MEMORY)" \
		$(TERRAFORM_FLAGS)

.PHONY: aws-init
aws-init:
	@:$(call check_defined, AWS_REGION, Amazon Region)
	@:$(call check_defined, AWS_ACCESS_KEY_ID, Amazon Access Key ID)
	@:$(call check_defined, AWS_SECRET_ACCESS_KEY, Amazon Secret Access Key)
	@:$(call check_defined, IMAGE, Docker image to run)
	@:$(call check_defined, PORT, Port to expose)
	@:$(call check_defined, COUNT, Number of containers to run)
	@:$(call check_defined, CPU, Fargate instance CPU units to provision (1 vCPU = 1024 CPU units))
	@:$(call check_defined, MEMORY, Fargate instance memory to provision (in MiB))
	@cd $(AWS_DIR) && terraform init \
		$(AWS_TERRAFORM_FLAGS)

.PHONY: aws-plan
aws-plan: aws-init ## Run terraform plan for Amazon.
	@cd $(AWS_DIR) && terraform plan \
		$(AWS_TERRAFORM_FLAGS)

.PHONY: aws-apply
aws-apply: aws-init ## Run terraform apply for Amazon.
	@cd $(AWS_DIR) && terraform apply \
		$(AWS_TERRAFORM_FLAGS)

.PHONY: aws-destroy
aws-destroy: aws-init ## Run terraform destroy for Amazon.
	@cd $(AWS_DIR) && terraform destroy \
		$(AWS_TERRAFORM_FLAGS)

check_defined = \
				$(strip $(foreach 1,$1, \
				$(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
				  $(if $(value $1),, \
				  $(error Undefined $1$(if $2, ($2))$(if $(value @), \
				  required by target `$@')))

.PHONY: update
update: update-terraform ## Update terraform binary locally.

TERRAFORM_BINARY:=$(shell which terraform || echo "/usr/local/bin/terraform")
TMP_TERRAFORM_BINARY:=/tmp/terraform
.PHONY: update-terraform
update-terraform: ## Update terraform binary locally from the docker container.
	@echo "Updating terraform binary..."
	$(shell docker run --rm --entrypoint bash r.j3ss.co/terraform -c "cd \$\$$(dirname \$\$$(which terraform)) && tar -Pc terraform" | tar -xvC $(dir $(TMP_TERRAFORM_BINARY)) > /dev/null)
	sudo mv $(TMP_TERRAFORM_BINARY) $(TERRAFORM_BINARY)
	sudo chmod +x $(TERRAFORM_BINARY)
	@echo "Update terraform binary: $(TERRAFORM_BINARY)"
	@terraform version

.PHONY: test
test: shellcheck ## Runs the tests on the repository.

# if this session isn't interactive, then we don't want to allocate a
# TTY, which would fail, but if it is interactive, we do want to attach
# so that the user can send e.g. ^C through.
INTERACTIVE := $(shell [ -t 0 ] && echo 1 || echo 0)
ifeq ($(INTERACTIVE), 1)
	DOCKER_FLAGS += -t
endif

.PHONY: shellcheck
shellcheck: ## Runs the shellcheck tests on the scripts.
	docker run --rm -i $(DOCKER_FLAGS) \
		--name shellcheck \
		-v $(CURDIR):/usr/src:ro \
		--workdir /usr/src \
		r.j3ss.co/shellcheck ./test.sh

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
