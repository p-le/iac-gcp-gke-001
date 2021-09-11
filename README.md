# How to use
**Gcloud SDK**, **terraform** will be executed inside Docker Container.

## Step 1: Update Makefile
Please update latest version of terraform, gcloud-sdk docker image
* TERRAFORM_VERSION: https://hub.docker.com/r/hashicorp/terraform/tags
* GCLOUD_SDK_VERSION: https://hub.docker.com/r/google/cloud-sdk/tags

## Step 2: Build local Gcloud image include Terraform
Merge terraform into gcloud sdk docker image
```
make build-gcloud-terraform-image
```

## Step 3: Prepare GCP Service Account

1. Click `Use this template`
2. Create new Service Account and download json credentials file using GCP Console
3. Copy Service Account JSON file to: `gcloud/credentials`
4. Update `CREDENTIAL_FILE :=` in Makefile
4. Active Service Account to gcloud SDK
```
make gcloud ARG="gcloud auth activate-service-account --key-file=/gcloud/credentials/****.json"
```

## Step 4: Config Github Repository Secrets for GitHub Actions
Github Actions also require these secret environments.
- AWS_ACCESS_KEY_ID: from Step 2
- AWS_SECRET_ACCESS_KEY: from Step 2
- TERRAFORM_CLOUD_API_TOKEN: Register Terraform Cloud and accquire at https://www.terraform.io/cloud


## Step 5: Write Terraform configuration files
1. `git checkout -b feature/xxx` or `git checkout -b hotfix/xxx`
2. Update backend.tf, change to your remote GCS bucket
	* `bucket`: Need to be created manually
	* `region`
	* `key`
3. Update `terraform.tfvars.example` if needed, then create `terraform.tfvars`
4. You can also use terraform command locally (Require Step2)
```
make terraform ARG=init
make terraform ARG=plan
make terraform ARG=apply
make terraform ARG=destroy
```
5. Commit, Push, and Create Pull Request to `main` branch
6. Confirm Github Actions Pipeline Result
7. If execution plan is fine, merge to master

