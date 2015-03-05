FROM ubuntu:trusty
# Based on the work of Fernando Mayo <fernando@tutum.co>, Feng Honglin <hfeng@tutum.co> (https://github.com/tutumcloud/tutum-docker-lamp).
MAINTAINER Gareth Foote <gareth.foote@gmail.com>

# Install packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install supervisor git apache2 libapache2-mod-php5 mysql-server php5-mysql pwgen php-pear php5-dev php5-gd libgd2-xpm-dev php5-curl
RUN pecl install timezonedb
RUN echo 'extension=timezonedb.so'> /etc/php5/mods-available/timezonedb.ini
RUN ls -la /etc/php5/apache2/
RUN ls -la /etc/php5/
RUN ln -sf /etc/php5/mods-available/timezonedb.ini /etc/php5/apache2/conf.d/30-timezonedb.ini
# - xdebug
RUN echo xdebug.remote_enable=1 >> /etc/php5/apache2/conf.d/20-xdebug.ini;\
    echo xdebug.remote_autostart=0 >> /etc/php5/apache2/conf.d/20-xdebug.ini;\
    echo xdebug.remote_connect_back=1 >> /etc/php5/apache2/conf.d/20-xdebug.ini;\
    echo xdebug.remote_port=9000 >> /etc/php5/apache2/conf.d/20-xdebug.ini;\
    echo xdebug.remote_log=/tmp/php5-xdebug.log >> /etc/php5/apache2/conf.d/20-xdebug.ini;

# Add image configuration and scripts
RUN mkdir -p /var/www/html
ADD start-apache2.sh /start-apache2.sh
ADD start-mysqld.sh /start-mysqld.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
ADD import_sql.sh /import_sql.sh
ADD create_db.sh /create_db.sh
RUN chmod 755 /*.sh

# config to enable .htaccess
ADD apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Configure /app folder with sample app
#RUN git clone https://github.com/fermayo/hello-world-lamp.git /app
RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html

RUN service apache2 restart

RUN mkdir /var/run/sshd
RUN restart ssh
RUN echo 'root:screencast' |chpasswd

# Add volumes for MySQL 
VOLUME  ["/etc/mysql", "/var/lib/mysql" ]

# Using a volume as source.
RUN rm -fr /app
EXPOSE 22 80 3306
CMD ["/run.sh"]
