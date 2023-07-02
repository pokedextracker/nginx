FROM nginx:1.24.0-alpine

RUN rm -f /etc/nginx/conf.d/default.conf
COPY ./conf.d /etc/nginx/conf.d
