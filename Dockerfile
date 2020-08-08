FROM		debian:buster

RUN			apt-get update && \
			apt-get install -y mariadb-server \
								supervisor \
								nginx \
								php-mysql \
								php-fpm \
								php \
								openssl


COPY		srcs/nginx/nginx.conf							/etc/nginx/nginx.conf
COPY		srcs/nginx/wordpress.conf						/etc/nginx/wordpress.conf
COPY		srcs/nginx/phpmyadmin.conf						/etc/nginx/phpmyadmin.conf
COPY		srcs/nginx/sites-available/default				/etc/nginx/sites-available/default

COPY		srcs/nginx/snippets/self-signed.conf	/etc/nginx/snippets/self-signed.conf
COPY		srcs/nginx/snippets/ssl-params.conf		/etc/nginx/snippets/ssl-params.conf

COPY		srcs/supervisor/supervisor.conf			/etc/supervisord.conf

COPY		srcs/wordpress							/var/www/wordpress
COPY		srcs/phpmyadmin							/var/www/phpmyadmin

RUN			chmod 777 /var/www/wordpress/

RUN			mkdir -p /var/run/php/


RUN			mkdir -p /var/run/mysqld && \
			touch /var/run/mysqld/mysqld.sock && \
			chown -R mysql /var/run/mysqld

RUN			sed -i 's/;   extension=mysqli/extension=mysqli.so/g' \
											/etc/php/7.3/cli/php.ini

RUN			service mysql start && \
			echo "GRANT ALL ON *.* TO admin@'%' IDENTIFIED BY 'admin' \
					WITH GRANT OPTION; FLUSH PRIVILEGES" | mysql

RUN			openssl req -new -newkey rsa:2048 -nodes -x509 -days 500 -subj \
			/C=RU/ST=Moscow/L=Moscow/O=Companyname/OU=User/CN=localhost/emailAddress=support@site.com \
			-keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt

COPY		srcs/dhparam.pem		/etc/ssl/certs/dhparam.pem

WORKDIR		/etc/nginx/

ENV			AUTOINDEX=on

ADD			srcs/autoindex.sh	/usr/bin/autoindex.sh

EXPOSE		80 443

CMD			["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
