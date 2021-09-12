#!/bin/bash

readonly SECRET_ID="gke-001-mysql-password"
readonly SECRET_VERSION=1 # NOTE: Update version to trigger null_resource
readonly K8S_SECRET="mysql"

DB_PASSWORD=$(gcloud secrets versions access $SECRET_VERSION --secret=$SECRET_ID --project=$GCP_PROJECT_ID)
kubectl create secret generic $K8S_SECRET \
    --from-literal username=wordpress \
    --from-literal password=$DB_PASSWORD
