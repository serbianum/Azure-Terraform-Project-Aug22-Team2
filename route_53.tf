provider "aws" {
    region = "eu-west-1"
    access_key=#add you access key
    secret_key=#added secret key
}

resource "aws_route53_record" "www" {
  zone_id = "Z08323833Z5X1YWJQRPX"
  name    = "team2.cloudjourneys.net"
  type    = "A"
  ttl     = 300
  records = [azurerm_public_ip.wordpress.ip_address]
}
