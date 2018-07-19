# -----------------------------------------------------------------------------
# Find instance size by name
# -----------------------------------------------------------------------------
data "oneandone_instance_size" "name" {
  name = "${var.instance_size}"
}

# -----------------------------------------------------------------------------
# Create bastion firewall policy
# -----------------------------------------------------------------------------
resource "oneandone_firewall_policy" "bastion" {
  name = "BOSH bastion"

  rules = [
    {
      "protocol"  = "TCP"
      "port_from" = 80
      "port_to"   = 80
      "source_ip" = "0.0.0.0"
    },
    {
      "protocol"  = "TCP"
      "port_from" = 443
      "port_to"   = 443
      "source_ip" = "0.0.0.0"
    },
    {
      "protocol"  = "TCP"
      "port_from" = 22
      "port_to"   = 22
      "source_ip" = "0.0.0.0"
    }
  ]
}

# -----------------------------------------------------------------------------
# Create bastion server
# -----------------------------------------------------------------------------
resource "oneandone_server" "bastion" {
  name                = "BOSH bastion"
  description         = "BOSH bastion server"
  image               = "${var.image}"
  datacenter          = "${var.datacenter}"
  fixed_instance_size = "${data.oneandone_instance_size.name.id}"
  ssh_key_public      = "${file(var.public_ssh_key_path)}"
  firewall_policy_id  = "${oneandone_firewall_policy.bastion.id}"
}

# -----------------------------------------------------------------------------
# Create BOSH private network 
# -----------------------------------------------------------------------------
resource "oneandone_private_network" "bosh_net" {
  name            = "BOSH network"
  description     = "BOSH private network"
  datacenter      = "${var.datacenter}"
  network_address = "${cidrhost(var.bosh_subnet, 0)}"
  subnet_mask     = "${cidrnetmask(var.bosh_subnet)}"

  server_ids = [
    "${oneandone_server.bastion.id}",
  ]
}

# -----------------------------------------------------------------------------
# Initialize the bastion server private network
# -----------------------------------------------------------------------------
resource "null_resource" "private_network" {
  depends_on = [ "oneandone_private_network.bosh_net" ]

  connection {
    private_key = "${file(var.private_ssh_key_path)}"
    host        = "${oneandone_server.bastion.ips.0.ip}"
    user        = "root"
  }

  provisioner "file" {
    source = "${path.module}/content/privatenet.sh"
    destination = "/tmp/privatenet.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "/bin/bash /tmp/privatenet.sh",
      "rm -f /tmp/privatenet.sh"
    ]
  }
}

# -----------------------------------------------------------------------------
# Bootstrap the bastion server
# -----------------------------------------------------------------------------
resource "null_resource" "bootstrap_bastion" {
  connection {
    private_key = "${file(var.private_ssh_key_path)}"
    host        = "${oneandone_server.bastion.ips.0.ip}"
    user        = "root"
  }

  provisioner "remote-exec" {
    inline = [
       "apt-get update",
       "apt-get -y --no-install-recommends install build-essential ruby ruby-dev libxml2-dev libsqlite3-dev libxslt1-dev libpq-dev libmysqlclient-dev zlib1g-dev git",
       "ssh-keygen -t rsa -N '' -f /root/.ssh/id_rsa",
       "curl -so /usr/local/bin/bosh https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-4.0.1-linux-amd64",
       "chmod 755 /usr/local/bin/bosh",
       "git clone --branch oneandone https://github.com/stackpointcloud/bosh-deployment.git /opt/bosh-deployment"
     ]
  }
}
