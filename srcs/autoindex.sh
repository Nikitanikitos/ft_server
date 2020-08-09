#!/bin/bash

echo $AUTOINDEX

if [ $AUTOINDEX = "off" ]
then
	sed -i 's/	autoindex	on;/		autoindex	off;/g' \
					/etc/nginx/sites-available/default
elif [ $AUTOINDEX = "on" ]
then
	sed -i 's/	autoindex	off;/		autoindex	on;/g' \
					/etc/nginx/sites-available/default
service nginx reload
fi

