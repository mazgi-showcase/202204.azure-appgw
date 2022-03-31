variable "project_unique_id" {}

variable "base_dnsdomain" {
  default = "example.dev"
}

variable "azure_default_location" {}

variable "webapp_name_list" {
  default = [
    "nginx",
    "httpd",
  ]
}
