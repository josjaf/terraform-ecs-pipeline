FROM public.ecr.aws/ubuntu/ubuntu:20.04

RUN apt-get update
RUN apt-get install -y nginx zip curl

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN curl -o /var/www/html/master.zip -L https://github.com/gabrielecirulli/2048/archive/master.zip
RUN rm -rf /var/www/html/index.nginx-debian.html && cd /var/www/html/ && unzip master.zip && mv 2048-master/* . && rm -rf 2048-master master.zip

# RUN curl -o /usr/share/nginx/www/master.zip -L https://github.com/gabrielecirulli/2048/archive/master.zip
# RUN cd /usr/share/nginx/www/ && unzip master.zip && mv 2048-master/* . && rm -rf 2048-master master.zip

EXPOSE 80

CMD ["/usr/sbin/nginx", "-c", "/etc/nginx/nginx.conf"]
