packer {
  required_plugins {
    hcloud = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/hcloud"
    }
  }
}

variable "talos_version" {
  type = string
}

variable "arch" {
  type = string
}

variable "image" {
  type = string
}

variable "features" {
  type = string
}

locals {
  features = var.features == "" ? [] : sort(split(" ", var.features))

  name = join("-", concat(
    ["talos", var.talos_version, var.arch],
    local.features
  ))

  labels = merge({
    os      = "talos",
    version = "${var.talos_version}",
    arch    = "${var.arch}"
  }, {
    for key in local.features : key => "enabled"
  })
}

source "hcloud" "talos" {
  rescue       = "linux64"
  image        = "debian-11"
  location     = "fsn1"
  server_type  = var.arch == "amd64" ? "cpx11" : "cax11"
  ssh_username = "root"

  snapshot_name   = local.name
  snapshot_labels = local.labels
}

build {
  sources = ["source.hcloud.talos"]
  provisioner "file" {
    source      = var.image
    destination = "/tmp/talos.raw.xz"
  }
  provisioner "shell" {
    inline = [
      "xz -d -c /tmp/talos.raw.xz | dd of=/dev/sda && sync",
    ]
  }
}
