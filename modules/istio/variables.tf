variable "name_prefix" {
  description = "name prefix"
}

variable "cluster_name" {
  type    = string
}

variable "helm_repository" {
  type    = string
}

variable "chart_version" {
  type    = string
}

variable "registry" {
  type    = string
}

variable "k8s_host" {
  type    = string
}

variable "k8s_cluster_ca_certificate" {
  type    = string
}

variable "k8s_client_token" {
  type    = string
}

variable "istio_cni" {
  type    = bool
  default = true
}

variable "istio_revisions"{
  type  = list(string)
}

variable "istio_flavor" {
  type = string
}