#!/usr/bin/env bash
# ------------------------------------------------------------------
# Task 10.2D - one-off bootstrap (run ONCE from your Mac, not in CI)
#
#  1. Creates a small resource group + storage account that holds the
#     Terraform remote state used by GitHub Actions.
#  2. Creates the service principal GitHub Actions uses to log in to Azure
#     and prints the JSON to paste into the AZURE_CREDENTIALS secret.
#
# Usage:  az login   then   bash infra/bootstrap.sh
# ------------------------------------------------------------------
set -euo pipefail

LOCATION="australiaeast"
TFSTATE_RG="rg-sit722-tfstate"
TFSTATE_SA="sttfstate${RANDOM}${RANDOM}"   # must be globally unique
TFSTATE_CONTAINER="tfstate"
SP_NAME="sp-sit722-week10-github"

SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "Subscription: ${SUBSCRIPTION_ID}"

echo "==> Creating Terraform state storage"
az group create -n "$TFSTATE_RG" -l "$LOCATION" -o none
az storage account create -n "$TFSTATE_SA" -g "$TFSTATE_RG" -l "$LOCATION" \
  --sku Standard_LRS --min-tls-version TLS1_2 --allow-blob-public-access false -o none
az storage container create --name "$TFSTATE_CONTAINER" \
  --account-name "$TFSTATE_SA" --auth-mode key -o none

echo "==> Creating service principal for GitHub Actions"
# Contributor: create/update resources.
# User Access Administrator: lets Terraform create the AKS -> ACR "AcrPull" role assignment.
az ad sp create-for-rbac --name "$SP_NAME" \
  --role Contributor \
  --scopes "/subscriptions/${SUBSCRIPTION_ID}" \
  --json-auth > sp.json

SP_APP_ID=$(jq -r .clientId sp.json)
az role assignment create --assignee "$SP_APP_ID" \
  --role "User Access Administrator" \
  --scope "/subscriptions/${SUBSCRIPTION_ID}" -o none \
  || echo "WARNING: could not grant User Access Administrator - set create_acr_role_assignment=false (see guide)."

echo
echo "================ ADD THESE TO GITHUB ================"
echo "Secret  AZURE_CREDENTIALS      = (contents of infra/sp.json - then DELETE sp.json)"
echo "Variable TFSTATE_RESOURCE_GROUP = ${TFSTATE_RG}"
echo "Variable TFSTATE_STORAGE_ACCOUNT = ${TFSTATE_SA}"
echo "====================================================="
