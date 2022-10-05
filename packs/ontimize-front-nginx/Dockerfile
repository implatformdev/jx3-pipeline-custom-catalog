FROM nginx:stable-alpine
COPY /dist /usr/share/nginx/html
COPY /nginx.conf /etc/nginx/conf.d/default.conf
COPY /setenv.sh /opt
RUN chmod +x /opt/setenv.sh
EXPOSE 80
CMD ["sh", "-c", "/opt/setenv.sh && nginx -g 'daemon off;'"]