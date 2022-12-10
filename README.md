# Terraform Project on Azure Team 2

Use Terraform to build a three-tier application on Azure to host WordPress.


## Prerequisites:

* [Terraform](https://www.terraform.io) 
* Azure subscription: If you don't have an Azure subscription, create a [free account](https://azure.microsoft.com/en-us/free)
* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)


* Login to your Azure Cloud Provider  
* Select Cost Management/ Billing Account under the hamburger menu 
* Create a Billing Account



## How to use

This project is configured to run by default with a .tfstate Azure backend configuration. Make sure you create your Microsoft Storage account, Azure Blob, Container and add the respective resources name in backend.tf file.

Otherwise comment out contents of backend.tf and run : 
  make <i>region</i> [specify the prefered region]

To destroy run :
  make <i>region</i>-destroy

## Route 53 Functionality
  To enable AWS Route 53 Record, open route_53.tf uncomment the code and fill out required aws account details.

## Reusability 
  This project is partially reusably. To make modifications to variable see <b>Variables.tf</b> file and set the desired values.


# Github 

Go to Github and create a repo for your project, dont forget to add .gitignore and README.md files 

This is group project, so add your collaborators into your project with their github names 

After adding them as collaborator, users will be able to add their SSH public keys to github successfully 

Users will be able to clone the project into their locals with git clone command 


# Documentation for .tf files

# RESOURCE GROUP + PROVIDER 
Create a resource group. Configure the Microsoft Azure Provider. 
Steps: 
Create Azure_Three_tier application Folder with .gitignore and README.md files
Under Azure_Three_tier Create a file  provider+rg.tf 
Use resource "azurerm_resource_group" "example"  to create resource group
Use resource provider "azurerm" features to create provider resource

```
# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used


# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

```


# VARIABLE.TF  
In this project we used variables to make our code more dynamic. Create a file variable.tf 
```
variable "location" {
  description = "The location where resources will be created"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of the tags to use for the resources that are deployed"
  type        = map(string)

  default = {
    environment = "DevOps"
  }
}

variable "application_port" {
  description = "The port that you want to expose to the external load balancer"
  default     = 80
}

variable "admin_username" {
  description = "User name to use as the admin account on the VMs that will be part of the VM Scale Set"
  default     = "wordpress"
}

variable "admin_password" {
  description = "Default password for admin account"
  default     = "26F4QXHVYbBjC$WH2HAc"
}

variable "dbname"{
  default = "db-wordpress-team2-aug22"
}

variable "db_server_name" {
 default = "team2-db-server-wordpress"
}

variable "database_admin_login" {
  default = "wordpress"
}

variable "database_admin_password" {
  default = "26F4QXHVYbBjC$WH2HAc"
}

variable "cidr_block" {
  description = "Provide CIDR Block"
  type        = list
  default     = ["10.0.0.0/16"]
}

variable "subnet_address"{
  description = "Provide subnet address space" 
  type        = list
  default     = ["10.0.1.0/24"]
}


```

 

# Vnet 
Next we created vnet.tf configuration file. Vnet is the Virtual Network which will include subnet that will associated with public ip. 

Steps: 
Use resource "azurerm_network_security_group" "example" to create the Vnet
Create vnet.tf file in folder with .gitignore and README.md files 

```
resource "azurerm_virtual_network" "wordpress" {
  name                = "wordpress-vnet"
  address_space       = var.cidr_block
  location            = var.location
  resource_group_name = azurerm_resource_group.wordpress.name
  tags                = var.tags
}

resource "azurerm_subnet" "wordpress" {
  name                 = "wordpress-subnet"
  resource_group_name  = azurerm_resource_group.wordpress.name
  virtual_network_name = azurerm_virtual_network.wordpress.name
  address_prefixes     = var.subnet_address
}

resource "azurerm_public_ip" "wordpress" {
  name                = "wordpress-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.wordpress.name
  allocation_method   = "Static"
  domain_name_label   = random_string.fqdn.result
  tags                = var.tags
}

```


# LB.tf & Scaleset.tf  
In LB.tf & Scaleset.tf files we used below resources: 
resource "azurerm_lb" "example" https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule
When setting up an Azure Load Balancer, you configure a health probe that your load balancer can use to determine if your instance is healthy.
Use resource "resource "azurerm_lb_rule" "example"  to create load balancer Rule 

The backend pool is a critical component of the load balancer. The backend pool defines the group of resources that will serve traffic for a given load-balancing rule.
Use resource https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool to create backend pool


```
resource "azurerm_lb" "wordpress" {
  name                = "wordpress-lb"
  location            = var.location
  resource_group_name = azurerm_resource_group.wordpress.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.wordpress.id
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  loadbalancer_id = azurerm_lb.wordpress.id
  name            = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "wordpress" {
  resource_group_name = azurerm_resource_group.wordpress.name
  loadbalancer_id     = azurerm_lb.wordpress.id
  name                = "ssh-running-probe"
  port                = var.application_port
}

resource "azurerm_lb_rule" "lbnatrule" {
  resource_group_name            = azurerm_resource_group.wordpress.name
  loadbalancer_id                = azurerm_lb.wordpress.id
  name                           = "http"
  protocol                       = "Tcp"
  frontend_port                  = var.application_port
  backend_port                   = var.application_port
  backend_address_pool_id        = azurerm_lb_backend_address_pool.bpepool.id
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.wordpress.id
}


resource "azurerm_linux_virtual_machine_scale_set" "wordpress" {
  name                            = "vmscaleset"
  location                        = var.location
  resource_group_name             = azurerm_resource_group.wordpress.name
  sku                             = "Standard_D2S_v3"
  instances                       = 1
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  custom_data = filebase64("customdata.tpl")
 source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7_9-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "NetworkInterface"
    primary = true

    ip_configuration {
      name                                   = "IPConfiguration"
      subnet_id                              = azurerm_subnet.wordpress.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
      primary                                = true
    }
  }

  tags = var.tags
}


```

 
# DATABASE.TF  

We used Azure Database for MySQL it's  a fully managed database service, which means that Microsoft automates the management and maintenance of your infrastructure and database server, including routine updates, backups and security.
Azure Database for MySQL is easy to set up, operate, and scale.
Use resource https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_server to create Database. 

```
# Create MySQL Server
resource "azurerm_mysql_server" "wordpress" {
  resource_group_name = azurerm_resource_group.wordpress.name
  name                = "team2-db-server-wordpress"   #"${var.db_server_name}-${(random_string.fqdn.result)}"
  location            = azurerm_resource_group.wordpress.location
  version             = "5.7"

  administrator_login          = var.database_admin_login
  administrator_login_password = var.database_admin_password

  sku_name                     = "GP_Gen5_4"
  storage_mb                   = "102400"
  auto_grow_enabled            = false
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  infrastructure_encryption_enabled = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = false
  #ssl_minimal_tls_version_enforced = "TLS1_2"
}

# Create MySql DataBase
resource "azurerm_mysql_database" "wordpress" {
  name                = var.dbname
  resource_group_name = azurerm_resource_group.wordpress.name
  server_name         = azurerm_mysql_server.wordpress.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

# Config MySQL Server Firewall Rule
resource "azurerm_mysql_firewall_rule" "wordpress" {
  name                = "wordpress-mysql-firewall-rule"
  resource_group_name = azurerm_resource_group.wordpress.name
  server_name         = azurerm_mysql_server.wordpress.name
  start_ip_address    = azurerm_public_ip.wordpress.ip_address
  end_ip_address      = azurerm_public_ip.wordpress.ip_address
}

data "azurerm_mysql_server" "wordpress" {
  name                = azurerm_mysql_server.wordpress.name
  resource_group_name = azurerm_resource_group.wordpress.name
}
```

 
#Output.tf
Output values make information about your infrastructure available on the command line, and can expose information for other Terraform configurations to use. Output values are similar to return values in programming languages.

```
output "application_public_address" {
  value = azurerm_public_ip.wordpress.fqdn
}


#CUTOMDATA.TPL
Customdata installing httpd and wordpress to our instances so in siple terms with using customdata(userdata) for BOOTSTRAPING

#!/bin/bash
sudo yum install httpd wget unzip epel-release mysql -y
sudo yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
sudo yum -y install yum-utils
sudo yum-config-manager --enable remi-php56   [Install PHP 5.6]
sudo yum -y install php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xf latest.tar.gz -C /var/www/html/
sudo mv /var/www/html/wordpress/* /var/www/html/
sudo cp /var/www/html/wp-config-sample.php  /var/www/html/wp-config.php 
sudo sed 's/database_name_here/db-wordpress-team2-aug22/g' /var/www/html/wp-config.php -i
sudo sed 's/username_here/wordpress@team2-db-server-wordpress/g' /var/www/html/wp-config.php -i
sudo sed 's/password_here/26F4QXHVYbBjC$WH2HAc/g' /var/www/html/wp-config.php -i
sudo sed 's/localhost/team2-db-server-wordpress.mysql.database.azure.com/g' /var/www/html/wp-config.php -i
sudo getenforce
sudo sed 's/SELINUX=permissive/SELINUX=enforcing/g' /etc/sysconfig/selinux -i
sudo setenforce 0
sudo chown -R apache:apache /var/www/html/
sudo systemctl start httpd
sudo systemctl enable httpd

```