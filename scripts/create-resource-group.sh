#!/usr/bin/env bash
# One-time setup: creates the resource group that network/virtual_machine/aks
# units deploy into (see environments/commonenv/common.hcl). None of the
# modules create this themselves — it must already exist before `terragrunt
# apply`. Safe to re-run — every step is idempotent.
#
# Usage: scripts/create-resource-group.sh
# Override defaults via env vars: RESOURCE_GROUP, LOCATION
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMMON_HCL="${REPO_ROOT}/environments/commonenv/common.hcl"

common_rg="$(grep -E '^\s*resource_group_name\s*=' "${COMMON_HCL}" | head -n1 | sed -E 's/.*"(.*)".*/\1/')"
common_location="$(grep -E '^\s*location\s*=' "${COMMON_HCL}" | head -n1 | sed -E 's/.*"(.*)".*/\1/')"

RESOURCE_GROUP="${RESOURCE_GROUP:-${common_rg}}"
LOCATION="${LOCATION:-${common_location}}"

if [[ "${RESOURCE_GROUP}" != "${common_rg}" ]]; then
  echo "Warning: RESOURCE_GROUP (${RESOURCE_GROUP}) does not match resource_group_name in" >&2
  echo "         environments/commonenv/common.hcl (${common_rg}). terragrunt units will" >&2
  echo "         deploy into '${common_rg}', not '${RESOURCE_GROUP}', unless you update common.hcl too." >&2
  echo >&2
fi

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
    --tags environment=local managed_by=terragrunt \
    --output none
fi

echo
echo "Done. '${RESOURCE_GROUP}' matches environments/commonenv/common.hcl's resource_group_name,"
echo "so network/virtual_machine/aks units can now deploy into it."
