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

locals {
  image = "https://github.com/siderolabs/talos/releases/download/${var.talos_version}/hcloud-${var.arch}.raw.xz"
  name  = join("-", concat(
    ["talos", var.talos_version, var.arch]
  ))
}

source "hcloud" "talos" {
  rescue       = "linux64"
  image        = "debian-11"
  location     = "fsn1"
  server_type  = var.arch == "amd64" ? "cpx11" : "cax11"
  ssh_username = "root"

  snapshot_name = local.name
  snapshot_labels = {
    os      = "talos",
    version = "${var.talos_version}",
    arch    = "${var.arch}"
  }
}

build {
  sources = ["source.hcloud.talos"]
  provisioner "shell" {
    inline = [
      "apt-get install -y wget",
      "wget -O /tmp/talos.raw.xz ${local.image}",
      "xz -d -c /tmp/talos.raw.xz | dd of=/dev/sda && sync",
    ]
  }
}
