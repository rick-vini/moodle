#!/bin/bash

apt-get install apache2 php7.3 mariadb-server php7.3-mysql libapache2-mod-php7.3 php7.3-gd php7.3-curl php7.3-xmlrpc php7.3-intl php7.3-zip php7.3-mbstring

cp -a /etc/php/7.3/apache2/php.ini /etc/php/7.3/apache2/php.ini.original

sed -i 's/post_max_size = 8M/post_max_size = 80M/g' /etc/php/7.3/apache2/php.ini

sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 80M/g' /etc/php/7.3/apache2/php.ini

apt-get update

apt-get install unzip

wget https://download.moodle.org/download.php/stable38/moodle-latest-38.zip

unzip moodle-latest-38.zip

mv moodle /var/www

cd /var/www

mkdir /var/www/moodledata

chown -R www-data:www-data moodle

chown -R www-data:www-data moodledata

chmod -R 755 moodle

chmod -R 755 moodledata

##################### Pagina ############

# vi /etc/apache2/sites-available/default
#On about line 4, change DocumentRoot "/var/www/html" to

#DocumentRoot "/var/www/moodle"
#On about line 10, change <Directory "/var/www/html/"> to

#<Directory "/var/www/moodle/">
#Around line 17, comment out the line for the default page:

# RedirectMatch ^/$ /apache2-default/
#You can change other values like ServerAdmin if appropriate. For all changes, you should restart Apache for the new settings to take effect.

#/etc/init.d/apache2 restart

############### CRON ###############

# crontab -u www-data -e

# */10 * * * * /usr/bin/php /var/www/moodle/admin/cli/cron.php  >/dev/null
