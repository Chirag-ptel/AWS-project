FROM yobasystems/alpine-nginx

COPY nginx.conf /etc/nginx/nginx.conf
COPY crontab.* .
COPY start.sh entrypoint-wrapper.sh
COPY rotatenginxlogs.sh /usr/local/sbin/rotatenginxlogs.sh

RUN apk add --update --no-cache bash dos2unix

RUN chmod +x entrypoint-wrapper.sh
RUN chmod +x /usr/local/sbin/rotatenginxlogs.sh

RUN dos2unix crontab.*

ENTRYPOINT ["/entrypoint-wrapper.sh"]