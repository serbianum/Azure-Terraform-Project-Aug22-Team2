provider "aws" {
    region = "us-east-2"
    access_key=#add you access key
    secret_key=#add your secret key
}

resource "aws_route53_record" "www" {
  zone_id = #add zone ID
  name    = #add name
  type    = "A"
  ttl     = 300
  records = [azurerm_public_ip.wordpress.ip_address]
}
