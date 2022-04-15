variable "project_unique_id" {}

variable "allowed_ipaddr_list" {
  type = list(any)
}

variable "azure_default_location" {}

variable "webapp_name_list" {
  default = [
    "nginx",
    "httpd",
  ]
}
