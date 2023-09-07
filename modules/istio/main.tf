provider "helm" {
  kubernetes {
    host                   = var.k8s_host
    cluster_ca_certificate = base64decode(var.k8s_cluster_ca_certificate)
    token                  = var.k8s_client_token
  }
}

provider "kubectl" {
  host                   = var.k8s_host
  cluster_ca_certificate = base64decode(var.k8s_cluster_ca_certificate)
  token                  = var.k8s_client_token
  load_config_file       = false
}

provider "kubernetes" {
  host                   = var.k8s_host
  cluster_ca_certificate = base64decode(var.k8s_cluster_ca_certificate)
  token                  = var.k8s_client_token
}

resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
  }
  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "helm_release" "istio_base" {
  name                = "istio-base"
  repository          = var.helm_repository
  chart               = "base"
  version             = var.chart_version
  namespace           = "istio-system"
  timeout             = 900
}

resource "helm_release" "istio_cni" {
  count = var.istio_cni ? 1 : 0
  name                = "istio-cni"
  repository          = var.helm_repository
  chart               = "cni"
  version             = var.chart_version
  namespace           = "kube-system"
  timeout             = 900
  values = [templatefile("${path.module}/manifests/istio/istio-cni.yaml.tmpl", {
   istio_flavor   = "${var.chart_version}-${var.istio_flavor}-v0"
  })]
}

resource "helm_release" "istiod" {
  count = length(var.istio_revisions)
  name                = var.istio_revisions[count.index] == "default" ? "istiod" : "istiod-${var.istio_revisions[count.index]}"
  repository          = var.helm_repository
  chart               = "istiod"
  version             = var.chart_version
  namespace           = "istio-system"
  timeout             = 900
  values = [templatefile("${path.module}/manifests/istio/istiod.yaml.tmpl", {
    istio_cni      = var.istio_cni
    istio_revision = var.istio_revisions[count.index]
    istio_flavor   = "${var.chart_version}-${var.istio_flavor}-v0"
  })]
  depends_on = [helm_release.istio_base]
}
