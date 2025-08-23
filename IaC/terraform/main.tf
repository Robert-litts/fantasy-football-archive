terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}

# Set the variable value in *.tfvars file
# or using the -var="hcloud_token=..." CLI option
variable "hcloud_token" {
  sensitive = true
}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
}

data "hcloud_image" "packer_snapshot" {
  with_selector = "app=docker"
  most_recent = true
}

data "hcloud_ssh_key" "default" {
  name = "robbie@Robbie-Dell-XPS"
}

resource "hcloud_firewall" "football-firewall" {
  name = "football-firewall"
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
    description = "Allow web traffic in"

  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "80"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
    description = "Allow web traffic in"
  }

   rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
    description = "Allow SSH in"

  }

}


resource "hcloud_server" "from_snapshot" {
  name        = "from-snapshot"
  image       = data.hcloud_image.packer_snapshot.id
  server_type = "cx22"
firewall_ids = [hcloud_firewall.football-firewall.id]
  ssh_keys = [ data.hcloud_ssh_key.default.id ]
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}

variable "cloudflare_api_token" {
  type        = string
  description = "API token for Cloudflare"
  sensitive   = true
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Zone ID fdomain in Cloudflare"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "cloudflare_dns_record" "hetzner_server" {
  zone_id = var.cloudflare_zone_id
  name    = "demboys"
  type    = "A"
  content   = hcloud_server.from_snapshot.ipv4_address
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "hetzner_server_ipv6" {
  zone_id = var.cloudflare_zone_id
  name    = "demboys"
  type    = "AAAA"
  content   = hcloud_server.from_snapshot.ipv6_address
  ttl     = 1
  proxied = true
}