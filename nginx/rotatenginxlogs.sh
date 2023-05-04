#!/bin/bash
DATE=$(date +%Y-%m-%d-%H%M)
mv /var/log/nginx/access.log /var/log/nginx/nginx.access.log.$DATE
mv /var/log/nginx/error.log /var/log/nginx/nginx_error.log.$DATE
kill -USR1 `cat /var/run/nginx.pid`
sleep 1
gzip /var/log/nginx/access.log.$DATE
gzip /var/log/nginx/error.log.$DATE