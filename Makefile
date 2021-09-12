BASE_PATH 			:= $(shell pwd)
TERRAFORM_VERSION	:= 1.0.6
GCLOUD_SDK_VERSION	:= 356.0.0-slim
KUBECTL_VERSION		:= 1.20.10
CREDENTIAL_FILE		:= multicloud-architect-b5e6e149-4538bfe25d0e.json

.PHONY: build-gcloud-terraform-image
build-gcloud-terraform-image:
	@docker image build \
		--build-arg GCLOUD_SDK_VERSION=$(GCLOUD_SDK_VERSION) \
		--build-arg TERRAFORM_VERSION=$(TERRAFORM_VERSION) \
		--build-arg KUBECTL_VERSION=$(KUBECTL_VERSION) \
		-t gcloud:$(GCLOUD_SDK_VERSION) \
		.

.PHONY: gcloud
gcloud:
	@docker container run -it --rm \
		-v ${BASE_PATH}/gcloud/.kube:/root/.kube \
		-v ${BASE_PATH}/gcloud/config:/gcloud/config \
		-v ${BASE_PATH}/gcloud/credentials:/gcloud/credentials \
		-e CLOUDSDK_CONFIG=/gcloud/config \
		gcloud:$(GCLOUD_SDK_VERSION) \
			$(ARG)

.PHONY: terraform-infra
terraform-infra:
	@docker container run -it --rm \
		-v ${BASE_PATH}/gcloud/.kube:/root/.kube \
		-v ${BASE_PATH}/gcloud/config:/gcloud/config \
		-v ${BASE_PATH}/gcloud/credentials:/gcloud/credentials \
		-v $(BASE_PATH)/src:/work \
		-e GOOGLE_APPLICATION_CREDENTIALS=/gcloud/credentials/$(CREDENTIAL_FILE) \
		-e CLOUDSDK_CONFIG=/gcloud/config \
		gcloud:$(GCLOUD_SDK_VERSION) terraform  -chdir=/work/infra $(ARG)

.PHONY: terraform-app
terraform-app:
	@docker container run -it --rm \
		-v ${BASE_PATH}/gcloud/.kube:/root/.kube \
		-v ${BASE_PATH}/gcloud/config:/gcloud/config \
		-v ${BASE_PATH}/gcloud/credentials:/gcloud/credentials \
		-v $(BASE_PATH)/src:/work \
		-e GOOGLE_APPLICATION_CREDENTIALS=/gcloud/credentials/$(CREDENTIAL_FILE) \
		-e CLOUDSDK_CONFIG=/gcloud/config \
		gcloud:$(GCLOUD_SDK_VERSION) terraform  -chdir=/work/app $(ARG)
