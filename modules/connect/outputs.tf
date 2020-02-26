output "private_ip_addresses" {
  description = "The list of private ip addresses belonging to the kafka connect instances"
  value = aws_instance.kafka_connect.*.private_ip
}