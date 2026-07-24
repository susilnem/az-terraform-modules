#!/usr/bin/env bash
# Refreshes every module's provider lock file (.terraform.lock.hcl) using the
# Terraform version pinned in mise.toml.
# Usage: scripts/update-lock-files.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MISE_FILE="${REPO_ROOT}/mise.toml"

pinned_version="$(grep -E '^terraform = ' "${MISE_FILE}" | sed -E 's/.*"(.*)"/\1/')"
if [[ -z "${pinned_version}" ]]; then
  echo "Error: couldn't find a 'terraform = \"...\"' line in ${MISE_FILE}." >&2
  exit 1
fi

# Prefer a real `terraform` binary since that's what's pinned; fall back to `tofu`.
tf_bin=""
if command -v terraform >/dev/null 2>&1; then
  tf_bin="terraform"
elif command -v tofu >/dev/null 2>&1; then
  tf_bin="tofu"
else
  echo "Error: neither 'terraform' nor 'tofu' is on PATH — can't refresh lock files." >&2
  exit 1
fi

if command -v jq >/dev/null 2>&1; then
  installed_version="$("${tf_bin}" version -json | jq -r '.terraform_version')"
else
  installed_version="$("${tf_bin}" version -json | grep -o '"terraform_version"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4)"
fi

if [[ "${installed_version}" != "${pinned_version}" ]]; then
  echo "Warning: installed ${tf_bin} is ${installed_version}, not the pinned ${pinned_version}." >&2
  echo "         Lock files below will be generated against ${installed_version}'s provider" >&2
  echo "         resolution, not ${pinned_version}'s. Install ${pinned_version} (tfenv/mise/asdf) for an exact match." >&2
fi

echo "Refreshing provider lock files with '${tf_bin} init -upgrade' (pinned Terraform version: ${pinned_version})..."
for module_dir in "${REPO_ROOT}"/modules/*/; do
  module_name="$(basename "${module_dir}")"
  echo "== ${module_name} =="
  (cd "${module_dir}" && "${tf_bin}" init -upgrade -backend=false -input=false >/dev/null && echo "  .terraform.lock.hcl refreshed")
  rm -rf "${module_dir}/.terraform"
done

echo
echo "Done. Remaining manual steps:"
echo "  - Review changed modules/*/.terraform.lock.hcl (currently gitignored by *.lock.hcl — say"
echo "    the word if you want to start committing them for reproducibility)."
echo "  - Re-run: cd modules/<name> && terraform init -backend=false && terraform test"
