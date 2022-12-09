output "application_public_address" {
  value = azurerm_public_ip.wordpress.fqdn
}
# output "application_public_address" {
#   value = azurerm_mysql_database.wordpress.server_name
# }
# output "wordpress_host"{
#   value=azurerm_mysql_server.wordpress.fqdn
# }
