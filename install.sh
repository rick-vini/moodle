#!/bin/bash

apt-get update

apt-get install -y unzip apache2 php7.3 php7.3-soap mariadb-server php7.3-mysql libapache2-mod-php7.3 php7.3-xml php7.3-gd php7.3-curl php7.3-xmlrpc php7.3-intl php7.3-zip php7.3-mbstring

cp -a /etc/php/7.3/apache2/php.ini /etc/php/7.3/apache2/php.ini.original

sed -i 's/post_max_size = 8M/post_max_size = 80M/g' /etc/php/7.3/apache2/php.ini

sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 80M/g' /etc/php/7.3/apache2/php.ini

cd /var/www

wget https://download.moodle.org/download.php/direct/stable38/moodle-latest-38.zip

unzip moodle-latest-38.zip

mkdir /var/www/moodledata

chown -R www-data:www-data /var/www/moodle

chown -R www-data:www-data /var/www/moodledata

chmod -R 755 /var/www/moodle

chmod -R 755 /var/www/moodledata

############## Banco ##########

mysqladmin -u root password "adminuser"

mysql -u root -p -e "CREATE USER 'valmor'@'%' IDENTIFIED BY 'adminuser';GRANT ALL PRIVILEGES ON  *.* to 'valmor'@'%' WITH GRANT OPTION;flush privileges;CREATE DATABASE moodle CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;CREATE USER 'moodleuser'@'localhost' IDENTIFIED BY 'adminuser';GRANT ALL PRIVILEGES ON moodle.* TO 'moodleuser'@'localhost';GRANT LOCK TABLES, SELECT ON *.* TO 'dumpuser'@'localhost' IDENTIFIED BY 'adminuser';"

#SHOW GRANTS FOR valmor;

systemctl restart mariadb.service

##################### Pagina ############

cp -a /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.original
cp -a /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf.original

sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/moodle/g' /etc/apache2/sites-available/000-default.conf
sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/moodle/g' /etc/apache2/sites-available/default-ssl.conf


######## HTTPS #######
mkdir /etc/apache2/ssl
#openssl req -x509 -nodes -days 1095 -newkey rsa:4096 -out /etc/apache2/ssl/server.crt -keyout /etc/apache2/ssl/server.key

a2enmod rewrite
a2enmod ssl
 
ln -s /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-enabled/000-default-ssl.conf
#vi /etc/apache2/sites-enabled/000-default-ssl.conf

#SSLCertificateFile    /etc/apache2/ssl/server.crt
#SSLCertificateKeyFile /etc/apache2/ssl/server.key

sed -i '/ServerAdmin/a RewriteEngine On\
RewriteCond %{HTTPS} !=on\
RewriteRule ^/?(.*) https://%{SERVER_NAME}/$1 [R,L]' /etc/apache2/sites-available/000-default.conf

/etc/init.d/apache2 restart

############### CRON ###############

(crontab -u www-data -l 2>/dev/null; echo "*/10 * * * * /usr/bin/php /var/www/moodle/admin/cli/cron.php  >/dev/null") | crontab -u www-data -

# crontab -u www-data -e
# */10 * * * * /usr/bin/php /var/www/moodle/admin/cli/cron.php  > /dev/null

#########  BKP  ##########

# Script que realiza o dump do banco do roundcube. Mantem as ultimas 7 copias por seguranca
# Criado por ricardo

DATADIR="/home/adminuser/"
USERNAME="dumpuser"
PASSWORD="adminuser"
NOW=$(date +"%d-%m-%Y")

#Faz Backup colocando a data no nome do arquivo
/usr/bin/mysqldump -u $USERNAME -p$PASSWORD --databases moodle > $DATADIR/moodle.$NOW.sql
if [ "$?" -ne "0" ]; then
        echo "failed!"
        exit 1
fi
echo "Fim mysqldump"

tar -czf $DATADIR/moodle-$NOW.tar.gz /var/www/moodle
if [ "$?" -ne "0" ]; then
        echo "failed!"
        exit 1
fi
echo "Fim copia do diretorio moodle"

tar -czf $DATADIR/moodledata-$NOW.tar.gz /var/www/moodledata
if [ "$?" -ne "0" ]; then
        echo "failed!"
        exit 1
fi
echo "Fim copia do diretorio moodledata"


# Remove arquivos do diretório informado com mais de uma semana (7 dias)
find $DATADIR -mtime +6 -exec rm {} \;
