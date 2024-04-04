resource "scaleway_vpc" "kapsule" {
  region = "fr-par"
  name   = format("vpc-kapsule-%s", var.env)
  tags   = ["kapsule", var.env]
}

resource "scaleway_vpc_private_network" "kapsule" {
  region = "fr-par"
  name   = format("pn-kapsule-%s", var.env)
  vpc_id = scaleway_vpc.kapsule.id
  tags   = ["kapsule", var.env]
}

resource "scaleway_vpc_public_gateway_ip" "kapsule" {
  zone = "fr-par-2"
}

resource "scaleway_vpc_public_gateway" "kapsule" {
  zone       = "fr-par-2"
  name       = format("gw-kapsule-%s", var.env)
  type       = "VPC-GW-M"
  ip_id      = scaleway_vpc_public_gateway_ip.kapsule.id
  tags       = ["kapsule", var.env]
  depends_on = [scaleway_vpc_private_network.kapsule]
  # to avoid race conditions, create PGW after PN
}

resource "scaleway_vpc_gateway_network" "kapsule" {
  zone               = "fr-par-2"
  gateway_id         = scaleway_vpc_public_gateway.kapsule.id
  private_network_id = scaleway_vpc_private_network.kapsule.id
  enable_masquerade  = true
  ipam_config {
    push_default_route = true
  }
}

resource "time_sleep" "wait_for_pgw" { # wait 20s after creating the PGW network.)
  depends_on      = [scaleway_vpc_gateway_network.kapsule]
  create_duration = "20s"
}
