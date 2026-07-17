#!/usr/bin/env bash
# One-time setup: creates the resource group + storage account + container
# used as the Terraform remote state backend (see environments/root.hcl).
# Safe to re-run — every step is idempotent.
#
# Usage: scripts/create-backend.sh
# Override defaults via env vars: RESOURCE_GROUP, STORAGE_ACCOUNT, CONTAINER, LOCATION
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT_HCL="${REPO_ROOT}/environments/root.hcl"

root_rg="$(grep -E '^\s*resource_group_name\s*=' "${ROOT_HCL}" | head -n1 | sed -E 's/.*"(.*)".*/\1/')"
root_storage_account="$(grep -E '^\s*storage_account_name\s*=' "${ROOT_HCL}" | head -n1 | sed -E 's/.*"(.*)".*/\1/')"
root_container="$(grep -E '^\s*container_name\s*=' "${ROOT_HCL}" | head -n1 | sed -E 's/.*"(.*)".*/\1/')"

RESOURCE_GROUP="${RESOURCE_GROUP:-${root_rg}}"
STORAGE_ACCOUNT="${STORAGE_ACCOUNT:-${root_storage_account}}"
CONTAINER="${CONTAINER:-${root_container}}"
LOCATION="${LOCATION:-eastus}"

for pair in "RESOURCE_GROUP:${root_rg}" "STORAGE_ACCOUNT:${root_storage_account}" "CONTAINER:${root_container}"; do
  var_name="${pair%%:*}"
  expected="${pair#*:}"
  actual="${!var_name}"
  if [[ "${actual}" != "${expected}" ]]; then
    echo "Warning: ${var_name} (${actual}) does not match environments/root.hcl's generated" >&2
    echo "         backend config (${expected}). terragrunt units will use '${expected}', not" >&2
    echo "         '${actual}', unless you update environments/root.hcl too." >&2
    echo >&2
  fi
done

if ! command -v az >/dev/null 2>&1; then
  echo "Error: Azure CLI ('az') is not installed." >&2
  exit 1
fi

if ! az account show >/dev/null 2>&1; then
  echo "Error: not logged in. Run 'az login' first." >&2
  exit 1
fi

echo "Using subscription: $(az account show --query name -o tsv)"
echo

echo "== Resource group: ${RESOURCE_GROUP} (${LOCATION}) =="
if az group show --name "${RESOURCE_GROUP}" >/dev/null 2>&1; then
  echo "Already exists, skipping create."
else
  az group create \
    --name "${RESOURCE_GROUP}" \
    --location "${LOCATION}" \
    --output none
fi

echo "== Storage account: ${STORAGE_ACCOUNT} =="
if az storage account show --name "${STORAGE_ACCOUNT}" --resource-group "${RESOURCE_GROUP}" >/dev/null 2>&1; then
  echo "Already exists, skipping create."
else
  az storage account create \
    --name "${STORAGE_ACCOUNT}" \
    --resource-group "${RESOURCE_GROUP}" \
    --location "${LOCATION}" \
    --sku Standard_LRS \
    --min-tls-version TLS1_2 \
    --https-only true \
    --allow-blob-public-access false \
    --output none
fi

echo "== Blob container: ${CONTAINER} =="
if az storage container show --name "${CONTAINER}" --account-name "${STORAGE_ACCOUNT}" --auth-mode login >/dev/null 2>&1; then
  echo "Already exists, skipping create."
else
  az storage container create \
    --name "${CONTAINER}" \
    --account-name "${STORAGE_ACCOUNT}" \
    --auth-mode login \
    --output none
fi

echo
echo "Done. Backend ready:"
echo "  resource_group_name  = ${RESOURCE_GROUP}"
echo "  storage_account_name = ${STORAGE_ACCOUNT}"
echo "  container_name       = ${CONTAINER}"
echo
echo "These already match environments/root.hcl's generated backend config, so you can now run:"
echo "  cd environments/local && terragrunt run-all init"
