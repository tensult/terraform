# #Create Virtual Pricvate Gateway
# resource "aws_vpn_gateway" "vgw" {
#   tags {
#     Name = "vgw_prod"
#   }
# }

# #Attach Virtual Pricvate Gateway
# resource "aws_vpn_gateway_attachment" "vgw_attachment" {
#   vpc_id         = "${aws_vpc.shared.id}"
#   vpn_gateway_id = "${aws_vpn_gateway.vgw.id}"
# }

# #Enable Route Propagation
# resource "aws_vpn_gateway_route_propagation" "vgw_prop" {
#   vpn_gateway_id = "${aws_vpn_gateway.vgw.id}"
#   route_table_id = "${aws_route_table.rt-private-ss.id}"
# }