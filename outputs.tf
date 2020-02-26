
output "haproxy_private_ips" {
  value = length(aws_instance.ui_haproxy_private.*.private_ip) >=1 ? join(
      ",",formatlist("%s", aws_instance.ui_haproxy_private.*.private_ip),
  ) : "Private HAProxy disabled"
}

output "haproxy_public_ips" {
  value = length(aws_instance.ui_haproxy_public.*.public_ip) >=1 ? join(
      ",",formatlist("%s", aws_instance.ui_haproxy_public.*.public_ip),
  ) : "Public HAProxy disabled"
}