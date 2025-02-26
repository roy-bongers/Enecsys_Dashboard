#!/bin/bash
# script name: sudo_install_webserver.sh
##
echo "Update system first"
sleep 1
sudo apt-get update
sleep 1
echo "-------------------------------------------------------------"
echo "Install unzip"
sleep 1
sudo apt-get -y install unzip

sleep 2

echo "-------------------------------------------------------------"
echo "Start install of apache, mysql, phpmyadmin"
sleep 1
echo "-------------------------------------------------------------"
echo "Here we go"
echo "Step 1: install php, apache, mysql"

sleep 1
sudo apt-get -y install apache2 php php-mysql php-curl php-gd php-json mariadb-server mysql-client

echo "mariaDB will now be secured. When this installation is done the new Mysql ROOT password will be displayed. Make sure to copy it!!"

sleep 2
#install temp package
aptitude -y install expect
## added. Maria doesnt set password for root
## change this
mysql -u root -e "USE mysql; update user set plugin='' where User='root'; flush privileges;"

#random password generation based on openssl
MYSQL_ROOT_PASSWORD="$(openssl rand -hex 10)"
sleep 2

SECURE_MYSQL=$(expect -c "
set timeout 2
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"\r\"
expect \"Set root password?\"
send \"y\r\"
expect \"New password:\"
send \"$MYSQL_ROOT_PASSWORD\r\"
expect \"Re-enter new password:\"
send \"$MYSQL_ROOT_PASSWORD\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")

echo "$SECURE_MYSQL"

echo "Delete package expect"
sleep 2
#remove package again
aptitude -y purge expect

## should result in this when connecting again:
## pi@raspberrypi:~ $ sudo mysql -u root
## ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: NO)

sleep 2
echo "-------------------------------------------------------------"
echo "Step 3: restart apache2"
sleep 1
sudo service apache2 restart

sleep 2
echo "-------------------------------------------------------------"
echo "Step 4: Install phpmyadmin"
sleep 1
sudo apt-get -y install phpmyadmin
#press space to select apache2 followed by Tab and Enter to go on
#Configure database for phpmyadmin with dbconfig-common? no

sleep 2
echo "-------------------------------------------------------------"
echo "Step 5: echo add line to apache config ServerName 127.0.0.1"
sleep 1
/bin/echo "ServerName 127.0.0.1" >> /etc/apache2/apache2.conf

sleep 1
echo "-------------------------------------------------------------"
echo "Step 6: restart apache and mysql"
sudo service apache2 restart
sudo service mysql restart

sleep 2
echo "-------------------------------------------------------------"
echo "Copy this new Mysql Root password and keep it in a safe place:"
echo $MYSQL_ROOT_PASSWORD
echo "Installation Done! > Go to script No 3 "
