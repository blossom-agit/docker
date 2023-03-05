variable "name" {
  type = string
}
variable "cluster_state_bucket" {
  type = string
}
variable "cluster_state_bucket_region" {
  type = string
}
variable "cluster_state_key" {
  type = string
}
variable "ngc_api_key" {
  type      = string
  sensitive = true
}
variable "ngc_email" {
  type = string
}
variable "chart" {
  type = string
}
variable "chart_values_file" {
  type = string
}