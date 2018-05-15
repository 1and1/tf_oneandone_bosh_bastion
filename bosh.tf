# -----------------------------------------------------------------------------
# Fetch BOSH image SHA1
# -----------------------------------------------------------------------------
data "http" "image_sha1" {
  url = "${var.bosh_image_url}.sha1"
}

# -----------------------------------------------------------------------------
# Import BOSH image
# -----------------------------------------------------------------------------
resource "oneandone_image" "bosh" {
  datacenter = "${var.datacenter}"
  name       = "${var.director_name}"
  os_id      = "${var.os_id}"
  source     = "image"
  url        = "${var.bosh_image_url}"
}

# -----------------------------------------------------------------------------
# Generate BOSH stemcell metadata file
# -----------------------------------------------------------------------------
data "template_file" "bosh_stemcell" {
  template = "${file("content/stemcell.MF.tpl")}"

  vars {
    image_id = "${oneandone_image.bosh.id}"
    image_sha1 = "${data.http.image_sha1.body}"
  }
}

# -----------------------------------------------------------------------------
# Archive BOSH stemcell metadata
# -----------------------------------------------------------------------------
resource "local_file" "bosh_stemcell" {
  content  = "${data.template_file.bosh_stemcell.rendered}"
  filename = "${path.module}/content/stemcell/stemcell.MF"

  provisioner "local-exec" {
    command = "tar -czf ${path.module}/content/stemcell.tgz -C content/stemcell/ ."
  }
}

# -----------------------------------------------------------------------------
# Create BOSH environment
# -----------------------------------------------------------------------------
resource "null_resource" "bosh-env" {
  depends_on = [
    "null_resource.bootstrap_bastion",
    "local_file.bosh_stemcell"
  ]

  connection {
    private_key = "${file(var.private_ssh_key_path)}"
    host        = "${oneandone_server.bastion.ips.0.ip}"
    user        = "root"
  }

  provisioner "file" {
    source      = "${path.module}/content/stemcell.tgz"
    destination = "/opt/bosh-deployment/stemcell.tgz"
  }

  provisioner "remote-exec" {
    inline = [
       "cd /opt/bosh-deployment",
       "bosh create-env /opt/bosh-deployment/bosh.yml --state=state.json --vars-store=creds.yml -o /opt/bosh-deployment/1and1/cpi.yml -v director_name=${var.director_name} -v internal_cidr=${var.bosh_subnet} -v internal_gw=${cidrhost(var.bosh_subnet, 1)} -v internal_ip=${cidrhost(var.bosh_subnet, 2)} -v private_network_id=${oneandone_private_network.bosh_net.id} -v datacenter=${var.datacenter} -v private_key=/root/.ssh/id_rsa -v api_token=${var.api_token} -v ssh_key=\"$(cat /root/.ssh/id_rsa.pub)\""
     ]
  }
}
