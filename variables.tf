variable "private_ssh_key_path" {
  type = "string"
  default = "~/.ssh/id_rsa"
}

variable "public_ssh_key_path" {
  type = "string"
  default = "~/.ssh/id_rsa.pub"
}

variable "bosh_subnet" {
  type    = "string"
  default = "192.168.0.0/24"
}

variable "instance_size" {
  type    = "string"
  default = "L"
}

variable "datacenter" {
  type    = "string"
  default = "US"
}

variable "image" {
  type    = "string"
  default = "ubuntu1604-64std"
}
