variable "api_token" {
  type = "string"
}

variable "director_name" {
  type    = "string"
  default = "bosh"
}

variable "private_ssh_key_path" {
  type    = "string"
  default = "~/.ssh/id_rsa"
}

variable "public_ssh_key_path" {
  type    = "string"
  default = "~/.ssh/id_rsa.pub"
}

variable "datacenter" {
  type    = "string"
  default = "DE"
}

variable "bosh_subnet" {
  type    = "string"
  default = "192.168.0.0/24"
}

variable "instance_size" {
  type    = "string"
  default = "L"
}

variable "image" {
  type    = "string"
  default = "ubuntu1604-64min"
}

variable "bosh_image_url" {
  default = "https://oneandone-bosh.s3-de-central.profitbricks.com/bosh14.vdi"
}

variable "os_id" {
  type    = "string"
  default = "B77E19E062D5818532EFF11C747BD104"
}
