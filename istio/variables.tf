variable "name_prefix" {
  description = "name prefix"
}

variable "cluster_id" {
  type    = string
  default = null
}

variable "region" {
}

variable "k8s_cluster" {
  default = {
    cloud = "aws"
  }
}

variable "jumpbox_username" {
  default = "tetrate-admin"
}

variable "output_path" {
  default = "../../outputs"
}

variable "istio" {
  type    = map(any)
  default = {}
}

locals {
  istio_defaults = {
    fqdn                = "demo"
    version             = "1.18.2"
    password            = "tetrate-istio"
    helm_repository     = "https://tetratelabs.github.io/helm-charts/"
    cni                 = false
    revisions           = ["default", "prod", "dev"]
    flavor              = "tetratefips"
  }
  istio = merge(local.istio_defaults, var.istio)
}