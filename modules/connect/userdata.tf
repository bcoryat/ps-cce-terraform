###########################################
######## Kafka Connect Bootstrap ##########
###########################################

data "template_file" "kafka_connect_properties" {
  template = file("${path.module}/kafka-connect.properties")

  vars = {
    global_prefix              = var.global_prefix
    cluster_name               = var.cluster_name
    broker_list                = var.bootstrap_broker
    access_key                 = var.service_access_key
    secret_key                 = var.service_access_secret
    schema_registry_url        = var.schema_registry_url
    schema_registry_auth       = var.schema_registry_auth
  }
}

data "template_file" "kafka_connect_bootstrap" {
  template = file("${path.module}/kafka-connect.sh")

  vars = {
    kafka_connect_properties    = data.template_file.kafka_connect_properties.rendered
  }
}

