apt-get install apache2 php7.3 mariadb-server php7.3-mysql libapache2-mod-php7.3 php7.3-gd php7.3-curl php7.3-xmlrpc php7.3-intl php7.3-zip php7.3-mbstring

cp -a /etc/php/7.3/apache2/php.ini /etc/php/7.3/apache2/php.ini.original

sed -i 's/post_max_size = 8M/post_max_size = 80M/g' /etc/php/7.3/apache2/php.ini

sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 80M/g' /etc/php/7.3/apache2/php.ini





