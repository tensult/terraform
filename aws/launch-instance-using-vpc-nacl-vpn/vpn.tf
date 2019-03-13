# Create Customer Gateway
resource "aws_customer_gateway" "cgw" {
  bgp_asn    = 65000
  ip_address = "${var.customer_gw}"
  type       = "ipsec.1"

  tags {
    Name = "cgw-${var.customer}"
  }
}

# Fetching the Virtual Private Gateway
data "aws_vpn_gateway" "vgw" {
  filter {
    name   = "attachment.vpc-id"
    values = ["${data.aws_vpc.vpc_client.id}"]
  }
}

output "vgw" {
  value = "${data.aws_vpn_gateway.vgw.id}"
}

#Create VPN Tunnel

resource "aws_vpn_connection" "vpn" {
  vpn_gateway_id      = "${data.aws_vpn_gateway.vgw.id}"
  customer_gateway_id = "${aws_customer_gateway.cgw.id}"
  type                = "ipsec.1"
  static_routes_only  = true
 tags {
   Name = "vpn_${var.customer}"
  }
}