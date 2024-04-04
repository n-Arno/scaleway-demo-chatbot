resource "scaleway_lb_ip" "ip" {
  # We only create an IP, K8s will use it to create his LB service
  zone = "fr-par-2"
}

output "lb_ip" {
  value = scaleway_lb_ip.ip.ip_address
}
