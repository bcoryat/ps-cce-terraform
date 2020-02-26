
resource "aws_security_group" "kafka_connect" {
  count = var.cluster_size >= 1 ? 1 : 0

  name        = "kafka-connect-${var.global_prefix}"
  description = "Kafka Connect"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 8083
    to_port   = 8083
    protocol  = "tcp"

    #within private subnet allow anything to connect
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "kafka-connect-${var.global_prefix}"
  }
}



resource "aws_instance" "kafka_connect" {

  count                       = var.cluster_size
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  associate_public_ip_address = false
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = concat(var.security_group_ids, aws_security_group.kafka_connect.*.id)

  user_data = data.template_file.kafka_connect_bootstrap.rendered

  root_block_device {
    volume_type = "gp2"
    volume_size = 100
  }

  tags = {
    Name = "kafka-connect-${var.global_prefix}-${var.cluster_name}-${count.index}"
  }
}

