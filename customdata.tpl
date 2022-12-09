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
#DBNAME="db-wordpress-team2-aug22"
sudo getenforce
sudo sed 's/SELINUX=permissive/SELINUX=enforcing/g' /etc/sysconfig/selinux -i
sudo setenforce 0
sudo chown -R apache:apache /var/www/html/
sudo systemctl start httpd
sudo systemctl enable httpd

# DB_SERVER_NAME="team2-db-server-wordpress"


# export WORDPRESS_DB_HOST= "${DB_SERVER_NAME}.mysql.database.azure.com"
# export WORDPRESS_DB_USER= "wordpress@${DB_SERVER_NAME}"
# export WORDPRESS_DB_PASSWORD= "26F4QXHVYbBjC$WH2HAc"
# export WORDPRESS_DB_NAME= "${DBNAME}"