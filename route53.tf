
provider "aws" {
    region = "eu-west-1"
}

resource "aws_route53_record" "www" {
  zone_id = "Z08323833Z5X1YWJQRPX"
  name    = "team2.cloudjourneys.net"
  type    = "A"
  ttl     = 300
  records = [azurerm_lb.wordpress.ip]
}