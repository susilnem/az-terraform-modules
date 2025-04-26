# Azure Terraform modules

## Project Structure

```
/modules
    ├── network/          # Module for virtual networks and subnets
    ├── compute/          # Module for virtual machines and related resources
    ├── storage/          # Module for storage accounts and containers
    ├── security/         # Module for security groups and policies
/main.tf                # Main Terraform configuration file
/variables.tf           # Input variables for the project
/outputs.tf             # Output values for the project
/README.md              # Project documentation
```

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed
- Azure CLI installed and authenticated
- An Azure subscription

## Usage

1. Clone the repository:
     ```bash
     git clone https://github.com/your-repo/az-terraform-modules.git
     cd az-terraform-modules
     ```

2. Initialize Terraform:
     ```bash
     terraform init
     ```

3. Review and customize variables in `variables.tf`.

    ```hcl
    resource_group_name = "<your-resource-group-name>"
    location            = "<your-location>"

    vnet_config = {
        name          = "<your-vnet-name>"
        address_space = ["<your-address-space>"]
    }

    subnet_configs = {
        public = {
            address_prefixes = ["<your-public-subnet-prefix>"]
        }
        private = {
            address_prefixes = ["<your-private-subnet-prefix>"]
        }
    }

    nsg_configs = {
        public = {
            security_rules = [
                {
                    name                       = "<rule-name>"
                    priority                   = <priority>
                    direction                  = "<direction>"
                    access                     = "<access>"
                    protocol                   = "<protocol>"
                    source_port_range          = "<source-port-range>"
                    destination_port_range     = "<destination-port-range>"
                    source_address_prefix      = "<source-address-prefix>"
                    destination_address_prefix = "<destination-address-prefix>"
                }
            ]
        }
        private = {
            security_rules = [
                {
                    name                       = "<rule-name>"
                    priority                   = <priority>
                    direction                  = "<direction>"
                    access                     = "<access>"
                    protocol                   = "<protocol>"
                    source_port_range          = "<source-port-range>"
                    destination_port_range     = "<destination-port-range>"
                    source_address_prefix      = "<source-address-prefix>"
                    destination_address_prefix = "<destination-address-prefix>"
                }
            ]
        }
    }

    route_table_configs = {
        public = {
            routes = [
                {
                    name           = "<route-name>"
                    address_prefix = "<address-prefix>"
                    next_hop_type  = "<next-hop-type>"
                }
            ]
        }
        private = {
            routes = []
        }
    }

    vm_configs = {
        public-vm = {
            name                     = "<vm-name>"
            subnet_key               = "<subnet-key>"
            size                     = "<vm-size>"
            admin_username           = "<admin-username>"
            admin_ssh_key_public_key = "<path-to-public-key>"
            public_ip                = <true-or-false>
            os_image = {
                publisher = "<os-publisher>"
                offer     = "<os-offer>"
                sku       = "<os-sku>"
                version   = "<os-version>"
            }
        }
        private-vm = {
            name                     = "<vm-name>"
            subnet_key               = "<subnet-key>"
            size                     = "<vm-size>"
            admin_username           = "<admin-username>"
            admin_ssh_key_public_key = "<path-to-public-key>"
            public_ip                = <true-or-false>
            os_image = {
                publisher = "<os-publisher>"
                offer     = "<os-offer>"
                sku       = "<os-sku>"
                version   = "<os-version>"
            }
        }
    }
    ```

4. Plan the infrastructure:
     ```bash
     terraform plan
     ```

5. Apply the configuration:
     ```bash
     terraform apply
     ```

6. Destroy the infrastructure when no longer needed:
     ```bash
     terraform destroy
     ```

## Modules

### Network Module
Provisions virtual networks, subnets, and related resources.

### Compute Module
Manages virtual machines, availability sets, and related compute resources.

### Storage Module
Creates storage accounts, containers, and blob storage.

### Security Module
Configures network security groups, rules, and policies.

## Contributing

Contributions are welcome! Please submit a pull request or open an issue for any suggestions or improvements.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
