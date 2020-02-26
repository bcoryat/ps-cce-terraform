provider "aws" {
  profile = "ps"
  region  = "us-west-2"
  #  skip_requesting_account_id = true
  #  skip_credentials_validation = true
}

resource "aws_key_pair" "mykey" {
  key_name   = "john-holland"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6VKmPLs5hSiyyg++L3o9Q6YSDHguXXdezuUhiwR7ayulz1ZL+z+X1uvVZnTwDitIbGewXAox/4O3yKsD/J75FiMJdbEBN4e1n1NUiPQM8ttAgmMy699/4L6WREkqtXUQ0GDBX/poQpMOkUOfIpzXBBPJFQOJ4UyK2WrSO22Y/E6PbgXyqo8JIfo49E2XrMbEZKjKz7EB9ZYjhVDkZ974IVG2zibWTPusREyHBHnyOtIHofe5C+hZomImu0pdpGRZsw1EpNslO9pOaUS1+MxrAfiJZux1wCuvpmkriegSjXvvSiYC4zZb8rzMOcyXZGKdP5Rl3dESWm36M83Tnaj9QAQxIO4Jq6ABxPYv89KGHh/jYlB4x4GmplbKJGFEgWAdjNgyPvOLwzxp/IeYbmNFMCSXmH2nvbE8l/k4rrE930AJhmP7B3OkUHpbxZXkOYKjGjMwho+sAVXTIbTKIAj+GX5E37BCv+/gDRZbsK3YfN+ee1Aod2sVuJbHd7kRDuM0nn89qT71xRq4SirnQouyRKdvo5RmowlVboQzNfsaZlljsyHFlFQhxNobdP9jsDncsV0Vuvpn8E3shnWUv4CzDTBT5hsc/oK6KXpTcB3JOEL2zbGeDEYBeqVQi4DKY1zAIxyfDxPPPvyW0T7XDFeXkM9a6IfYIKLDvWuBSMn3eUw== john.o.holland@gmail.com"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_security_group" "allow_all_tls" {
  name        = "allow_all_tls"
  description = "Allow TLS inbound traffic from everywhere"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.global_prefix}-allow_all_tls"
  }
}

module "kafka_connect" {
  source = "./modules/connect"

  instance_type         = "t3.medium"
  cluster_size          = 1
  vpc_id                = "${var.vpc_id}"
  subnet_id             = "${var.subnet_private}"
  ami_id                = "${data.aws_ami.ubuntu.id}"
  key_name              = "${aws_key_pair.mykey.key_name}"
  global_prefix         = "${var.global_prefix}"
  cluster_name          = "general"
  security_group_ids    = ["${var.security_group_ps}"]
  schema_registry_url   = "${var.ccloud_schema_registry_url}"
  schema_registry_auth  = "${var.ccloud_schema_registry_basic_auth}"
  bootstrap_broker      = "${var.ccloud_broker_list}"
  service_access_key    = "2O2KD47KHKYERVFS"
  service_access_secret = "mzib0OJZNe45B+o+P41OfyLCJwNgLM+b08W5nJq3cgVvBZ+CLbtNuYmUieHcefyS"
}

module "kafka_connect_special" {
  source = "./modules/connect"

  instance_type         = "t3.medium"
  cluster_size          = 1
  vpc_id                = "${var.vpc_id}"
  subnet_id             = "${var.subnet_private}"
  ami_id                = "${data.aws_ami.ubuntu.id}"
  key_name              = "${aws_key_pair.mykey.key_name}"
  global_prefix         = "${var.global_prefix}"
  cluster_name          = "special"
  security_group_ids    = ["${var.security_group_ps}"]
  schema_registry_url   = "${var.ccloud_schema_registry_url}"
  schema_registry_auth  = "${var.ccloud_schema_registry_basic_auth}"
  bootstrap_broker      = "${var.ccloud_broker_list}"
  service_access_key    = "2O2KD47KHKYERVFS"
  service_access_secret = "mzib0OJZNe45B+o+P41OfyLCJwNgLM+b08W5nJq3cgVvBZ+CLbtNuYmUieHcefyS"
}

resource "aws_instance" "control_center" {
  # depends_on = [
  #   aws_instance.kafka_connect,
  #   aws_instance.ksql_server,
  # ]

  count                       = var.instance_count["control_center"] >= 1 ? 1 : 0
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "t3.large"
  key_name                    = "${aws_key_pair.mykey.key_name}"
  subnet_id                   = "${var.subnet_private}"
  vpc_security_group_ids      = [var.security_group_ps]
  associate_public_ip_address = false

  user_data = data.template_file.control_center_bootstrap.rendered

  root_block_device {
    volume_type = "gp2"
    volume_size = 300
  }

  tags = {
    Name = "${var.global_prefix}-c3-${count.index}"
  }
}

resource "aws_instance" "ui_haproxy_private" {
  count                       = var.instance_count["ui_haproxy_private"] >= 1 ? 1 : 0
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "t2.micro"
  key_name                    = "${aws_key_pair.mykey.key_name}"
  subnet_id                   = var.subnet_private
  vpc_security_group_ids      = ["${aws_security_group.allow_all_tls.id}", var.security_group_ps]
  availability_zone           = var.aws_availability_zone
  associate_public_ip_address = false

  user_data = data.template_file.haproxy_private_bootstrap.rendered

  tags = {
    Name = "${var.global_prefix}-ui-haproxy-private-${count.index}"
  }
}

resource "aws_instance" "ui_haproxy_public" {
  count                  = var.instance_count["ui_haproxy_public"] >= 1 ? 1 : 0
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.mykey.key_name}"
  subnet_id              = var.subnet_public
  vpc_security_group_ids = ["${aws_security_group.allow_all_tls.id}", var.security_group_ps]
  availability_zone      = var.aws_availability_zone

  user_data = data.template_file.haproxy_public_bootstrap.rendered

  tags = {
    Name = "${var.global_prefix}-ui-haproxy-public-${count.index}"
  }
}

resource "aws_instance" "bastion" {
  count                  = var.instance_count["bastion_server"] >= 1 ? 1 : 0
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.mykey.key_name}"
  subnet_id              = var.subnet_public
  vpc_security_group_ids = [var.security_group_ps]
  availability_zone      = var.aws_availability_zone

  tags = {
    Name = "${var.global_prefix}-bastion-${count.index}"
  }
}

resource "aws_instance" "cce_workbox" {
  count                       = var.instance_count["cce_workbox"] >= 1 ? 1 : 0
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "t2.micro"
  key_name                    = "${aws_key_pair.mykey.key_name}"
  subnet_id                   = "${var.subnet_private}"
  vpc_security_group_ids      = [var.security_group_ps]
  availability_zone           = "${var.aws_availability_zone}"
  associate_public_ip_address = false

  tags = {
    Name = "${var.global_prefix}-cce-box-${count.index}"
  }
}
