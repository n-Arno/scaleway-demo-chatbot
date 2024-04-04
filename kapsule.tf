data "scaleway_k8s_version" "latest" {
  region = "fr-par"
  name   = "latest"
}

resource "scaleway_k8s_cluster" "kapsule" {
  region                      = "fr-par"
  name                        = format("cluster-%s", var.env)
  version                     = data.scaleway_k8s_version.latest.name
  cni                         = "cilium"
  private_network_id          = scaleway_vpc_private_network.kapsule.id
  delete_additional_resources = true
  tags                        = ["kapsule", var.env]
  depends_on                  = [time_sleep.wait_for_pgw]
}

resource "scaleway_k8s_pool" "cpu" {
  zone                = "fr-par-2"
  cluster_id          = scaleway_k8s_cluster.kapsule.id
  name                = "cpu"
  node_type           = "PRO2-XXS"
  size                = 1
  autoscaling         = false
  autohealing         = true
  public_ip_disabled  = true
  wait_for_pool_ready = true
  depends_on          = [time_sleep.wait_for_pgw]
}

resource "scaleway_k8s_pool" "gpu" {
  zone                = "fr-par-2"
  cluster_id          = scaleway_k8s_cluster.kapsule.id
  name                = "gpu"
  node_type           = "L4-1-24G"
  size                = 1
  autoscaling         = false
  autohealing         = true
  public_ip_disabled  = true
  wait_for_pool_ready = true
  tags                = ["taint=node=gpu:NoSchedule"]
  depends_on          = [time_sleep.wait_for_pgw]
}

variable "hide" { # Workaround to hide local-exec output
  default   = "yes"
  sensitive = true
}

resource "null_resource" "kubeconfig" {
  depends_on = [scaleway_k8s_pool.cpu, scaleway_k8s_pool.gpu]
  triggers = {
    # following triggers are used to simplify access
    host                   = scaleway_k8s_cluster.kapsule.kubeconfig[0].host
    token                  = scaleway_k8s_cluster.kapsule.kubeconfig[0].token
    cluster_ca_certificate = scaleway_k8s_cluster.kapsule.kubeconfig[0].cluster_ca_certificate
    # Artificial trigger to re-run each time
    always_run = timestamp()
  }

  provisioner "local-exec" {
    environment = {
      HIDE_OUTPUT = var.hide # Workaround to hide local-exec output
    }
    command = <<-EOT
    cat<<EOF>kubeconfig.yaml
    apiVersion: v1
    clusters:
    - cluster:
        certificate-authority-data: ${self.triggers.cluster_ca_certificate}
        server: ${self.triggers.host}
      name: ${scaleway_k8s_cluster.kapsule.name}
    contexts:
    - context:
        cluster: ${scaleway_k8s_cluster.kapsule.name}
        user: admin
      name: admin@${scaleway_k8s_cluster.kapsule.name}
    current-context: admin@${scaleway_k8s_cluster.kapsule.name}
    kind: Config
    preferences: {}
    users:
    - name: admin
      user:
        token: ${self.triggers.token}
    EOF
    chmod 600 kubeconfig.yaml
    EOT
  }
}
