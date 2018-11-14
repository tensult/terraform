resource "aws_vpc_dhcp_options" "ad" {
  domain_name          = "${var.domain_name}"
  domain_name_servers  = "${concat(var.domain_dns_ips, var.amazon_dns)}"

  tags {
    Name = "ActiveDirectory"
  }
}

resource "aws_vpc_dhcp_options_association" "ad" {
  vpc_id          = "${var.vpc_id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.ad.id}"
}