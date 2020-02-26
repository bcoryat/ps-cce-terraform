variable "ccloud_broker_list" {
}

variable "ccloud_access_key" {
}

variable "ccloud_secret_key" {
}

variable "ccloud_control_plane_host" {
}

variable "ccloud_schema_registry_url" {
}

variable "ccloud_schema_registry_basic_auth" {
}

variable "aws_availability_zone" {
}

variable "vpc_id" {
}

variable "subnet_public" {
}

variable "subnet_private" {
}

variable "security_group_ps" {
}

variable "global_prefix" {
  default = "jholland"
}

variable "instance_count" {
  type    = map(string)

  default = {
    "cce_workbox" = 0
    "control_center" = 1
    "bastion_server" = 0
    "ui_haproxy_public" = 1
    "ui_haproxy_private" = 0
  }
}

variable "broker_count" {
  type    = number

  default = 4
}

variable "confluent_platform_location" {
  default = "http://packages.confluent.io/archive/5.3/confluent-5.3.1-2.12.zip"
}

variable "confluent_home_value" {
  default = "/etc/confluent/confluent-5.3.1"
}
