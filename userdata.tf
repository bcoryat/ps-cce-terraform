###########################################
########  HAProxy Bootstrap #########
###########################################
# data "template_file" "haproxy_cfg_public" {
#   template = file("util/haproxy.cfg")

#   vars = {
#     global_prefix              = var.global_prefix
#     proxy_ip                   = aws_instance.ui_haproxy_private.private_ip
#     control_plane_host         = var.ccloud_control_plane_host
#     broker_vip                 = var.ccloud_broker_list
#     broker_count               = var.broker_count
#   }
# }

data "template_file" "haproxy_public_bootstrap" {
# data "template_file" "haproxy_cfg_public" {
  template = file("util/haproxy.sh")

  vars = {
    haproxy_cfg                 = templatefile("util/haproxy.cfg", {
      global_prefix              = var.global_prefix
      proxy_ip                   = aws_instance.ui_haproxy_private[0].private_ip
      control_plane_host         = var.ccloud_control_plane_host
      broker_vip                 = split(":", var.ccloud_broker_list)[0]
      broker_count               = var.broker_count
     })
  }
}


# data "template_file" "haproxy_cfg_private" {
#   template = file("util/haproxy.cfg")

#   vars = {
#     global_prefix              = var.global_prefix
#     proxy_ip                   = ""
#     control_plane_host         = var.ccloud_control_plane_host
#     broker_vip                 = var.ccloud_broker_list
#     broker_count               = var.broker_count
#    }
# }

data "template_file" "haproxy_private_bootstrap" {
# data "template_file" "haproxy_cfg_private" {
  template = file("util/haproxy.sh")

  vars = {
    haproxy_cfg                 = templatefile("util/haproxy.cfg", { 
      global_prefix              = var.global_prefix
      proxy_ip                   = ""
      control_plane_host         = var.ccloud_control_plane_host
      broker_vip                 = split(":", var.ccloud_broker_list)[0]
      broker_count               = var.broker_count
    })
  }
}


###########################################
######## Control Center Bootstrap #########
###########################################

data "template_file" "control_center_properties" {
  template = file("util/control-center.properties")

  vars = {
    global_prefix              = var.global_prefix
    broker_list                = var.ccloud_broker_list
    access_key                 = var.ccloud_access_key
    secret_key                 = var.ccloud_secret_key
    schema_registry_url        = var.ccloud_schema_registry_url
    schema_registry_basic_auth = var.ccloud_schema_registry_basic_auth
    confluent_home_value       = var.confluent_home_value
    kafka_connect_url = join(
     ",",
      formatlist(
        "http://%s:%s",
        module.kafka_connect.private_ip_addresses,
        "8083",
      ),
    )
    kafka_connect_special_url = join(
     ",",
      formatlist(
        "http://%s:%s",
        module.kafka_connect_special.private_ip_addresses,
        "8083",
      ),
    )
#   ksql_server_url = join(
#     ",",
#     formatlist(
#       "http://%s:%s",
#       aws_instance.ksql_server.*.private_ip,
#       "8088",
#     ),
#   )
#   ksql_public_url = join(
#     ",",
#     formatlist("http://%s:%s", aws_alb.ksql_server.*.dns_name, "80"),
#   )
  }
}

data "template_file" "control_center_bootstrap" {
  template = file("util/control-center.sh")

  vars = {
    confluent_platform_location = var.confluent_platform_location
    control_center_properties   = data.template_file.control_center_properties.rendered
    confluent_home_value        = var.confluent_home_value
  }
}
