variable "instance_type" {
  description = "The type of EC2 Instances to run (e.g. t2.micro)"
  type        = string
  default     = "t3.medium"
}

variable "cluster_size" {
  description = "The number of instances to deploy"
  type        = number
  default     = 1
}

variable "vpc_id" {
  description = "The id of the vpc to put the instances in"
  type        = string
}

variable "subnet_id" {
  description = "The id of the subnet to put the instances in"
  type        = string
}

variable "ami_id" {
  description = "The ID of the AMI to use for the instances"
  type        = string
}

variable "key_name" {
  description = "The ssh key to use for the instances"
  type        = string
}

variable "global_prefix" {
  description = "A prefix used to namespace the instances"
  type        = string
}

variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
}

variable "security_group_ids" {
  description = "Security groups to apply to the instances"
  type        = list(string)
}

variable "schema_registry_url" {
  description = "The URL to the schema registry"
  type        = string
}

variable "schema_registry_auth" {
  description = "The authentication string for the schema registry"
  type        = string
}

variable "bootstrap_broker" {
  type = string
}

variable "service_access_key" {
  type = string
}

variable "service_access_secret" {
  type = string
}




