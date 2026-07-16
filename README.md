# Azure Terraform modules

## Project Structure

```
/modules
    ├── az_network/          # Module for virtual networks, subnets, NSGs, and route tables
    ├── az_virtual_machine/  # Module for Linux virtual machines and related resources
    ├── az_aks/              # Module for Azure Kubernetes Service clusters
/environments
    ├── root.hcl             # Shared terragrunt root config (remote state backend + provider generation)
    ├── commonenv/           # Shared variables (resource group, location, tags) for all environments
    ├── local/
        ├── network/         # terragrunt unit for az_network
        ├── virtual_machine/ # terragrunt unit for az_virtual_machine
        ├── aks/             # terragrunt unit for az_aks
/README.md               # Project documentation
```

## Prerequisites

- [mise](https://mise.jdx.dev/getting-started.html) — installs Terraform and Terragrunt at the versions pinned in [`mise.toml`](mise.toml) (`mise install`)
- [TFLint](https://github.com/terraform-linters/tflint) — version pinned directly in `.github/workflows/ci.yaml` (`pre_commit_check` job)
- Azure CLI installed and authenticated
- An Azure subscription
- To bump a pinned Terraform/Terragrunt version, edit `mise.toml` directly, then run `scripts/update-lock-files.sh` to refresh `modules/*/.terraform.lock.hcl` against the new Terraform version.

## Usage

1. Clone the repository:
     ```bash
     git clone https://github.com/your-repo/az-terraform-modules.git
     cd az-terraform-modules
     ```

2. Review and customize the shared variables in `environments/commonenv/common.hcl` (`resource_group_name`, `location`, `tags`), and the per-unit `inputs` in each `environments/local/*/terragrunt.hcl`.

3. Plan and apply a single unit, e.g. the network:
     ```bash
     cd environments/local/network
     terragrunt plan
     terragrunt apply
     ```

   Or plan/apply every unit together (network → virtual_machine/aks, respecting `dependency` blocks):
     ```bash
     cd environments/local
     terragrunt run-all plan
     terragrunt run-all apply
     ```

4. To update provider versions:
     ```bash
     terragrunt run-all init -upgrade
     ```

5. Destroy the infrastructure when no longer needed:
     ```bash
     terragrunt run-all destroy
     ```

## Modules

### Network Module (`modules/az_network`)
Provisions a virtual network, subnets, network security groups, and route tables. Validates CIDR blocks, NSG rule fields, and route next-hop types; asserts `nsg_configs`/`route_table_configs` keys match `subnet_configs` keys.

### Virtual Machine Module (`modules/az_virtual_machine`)
Provisions Linux VMs with SSH-key-only auth, managed boot diagnostics, and optional encryption-at-host and platform-managed patching (`patch_mode`/`patch_assessment_mode`, both default to `AutomaticByPlatform`).

### AKS Module (`modules/az_aks`)
Provisions an AKS cluster with optional private cluster mode, API server authorized IP ranges, Azure AD RBAC, local account disablement, OIDC issuer/workload identity, Microsoft Defender, and autoscaling node pools (default and additional).

### Shared: `tags`
Every module accepts a `tags` input (`map(string)`, default `{}`), applied to all taggable resources it creates. The example environments source a default tag set from `environments/commonenv/common.hcl`.

## Contributing

Contributions are welcome! Please submit a pull request or open an issue for any suggestions or improvements.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
