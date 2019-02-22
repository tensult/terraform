# #Create Customer Gateway of On-premises
# resource "aws_customer_gateway" "cgw" {
#   bgp_asn    = 65000
#   ip_address = "${var.customer_gw}"
#   type       = "ipsec.1"

#   tags {
#     Name = "cgw-fortigate-1a"
#   }
# }
