ARG TERRAFORM_VERSION
ARG GCLOUD_SDK_VERSION
ARG KUBECTL_VERSION

FROM hashicorp/terraform:$TERRAFORM_VERSION as terraform-base

FROM bitnami/kubectl:$KUBECTL_VERSION as kubectl-base

FROM google/cloud-sdk:$GCLOUD_SDK_VERSION

WORKDIR /work

COPY --from=terraform-base /bin/terraform /bin/terraform
COPY --from=kubectl-base /opt/bitnami/kubectl/bin/kubectl /bin/kubectl
