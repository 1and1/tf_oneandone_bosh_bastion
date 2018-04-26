## Usage

Create a Terraform config file. For example, `main.tf`.

    module "bosh_bastion" {
      source = "github.com/stackpointcloud/tf_oneandone_bosh_bastion"
    
      private_ssh_key_path = "/path/to/ssh/id_rsa"
      public_ssh_key_path = "/path/to/ssh/id_rsa.pub"
      bosh_subnet = "192.168.0.0/24"
      instance_size = "L"
      datacenter = "US"
      image = "ubuntu1604-64std"
    }

    output "bastion_ip" {
      value = "${module.bosh_bastion.bastion_ip}"
    }

Set 1&1 API token as an environment variable:

    export ONEANDONE_TOKEN=[token]

Initialize and run Terraform:

    terraform init
    terraform plan
    terraform apply

## Module Arguments

* `private_ssh_key_path` - (Optional) If omitted, `~/.ssh/id_rsa` is used.
* `public_ssh_key_path` - (Optional) If omitted, `~/.ssh/id_rsa.pub` is used.
* `bosh_subnet` - (Optional) If omitted, `192.168.0.0/24` is used.
* `instance_size` - (Optional) If omitted, `L` is used.
* `datacenter` - (Optional) If omitted, `US` is used.
* `image` - (Optional) If omitted, `ubuntu1604-64std` is used.
