oxipng_version := v9.1.5## Default oxipng version
pin_as_latest := 1
image := acsprime/oxipng
docker_hub_is_logged_in = $(shell docker info 2>/dev/null | grep -q "Username:" && echo 1)

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'


build: ## Build the Docker image for OxiPNG
	docker build \
      --build-arg OXIPNG_VERSION=$(oxipng_version) \
      -t $(image):$(oxipng_version) \
      $(if $(filter 1,$(pin_as_latest)),-t $(image):latest) \
      .

push: ## Push the Docker image to the registry
	$(if $(call docker_hub_is_logged_in),echo "You are logged in to docker hub",docker login -u acsprime)
	docker push $(image):$(oxipng_version)
	$(if $(filter 1,$(pin_as_latest)),docker push $(image):latest)

release-9.1.5: oxipng_version := v9.1.5
release-9.1.5: pin_as_latest := 0
release-9.1.5: release
release-9.1.5: ## Build and push the Docker image for OxiPNG v9.1.5

release-9.1.4: oxipng_version := v9.1.4
release-9.1.4: pin_as_latest := 0
release-9.1.4: release
release-9.1.4: ## Build and push the Docker image for OxiPNG v9.1.4

release: build
release: push
release: ## Build and push the Docker image for latest OxiPNG
	@echo "OxiPNG Docker image $(oxipng_version) released successfully$(if $(filter 1,$(pin_as_latest)), and was also set to latest)."

clean: ## Clean up the Docker images
	-docker rmi $(image):$(oxipng_version)
	-docker rmi $(image):latest