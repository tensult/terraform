# #Create VPN 
# resource "aws_vpn_connection" "vpn_frotigate" {
#   vpn_gateway_id      = "${aws_vpn_gateway.vgw.id}"
#   customer_gateway_id = "${aws_customer_gateway.cgw.id}"
#   type                = "ipsec.1"
#   static_routes_only  = false
#  tags {
#    Name = "vpn_frotigate_1a"
#   }
# }