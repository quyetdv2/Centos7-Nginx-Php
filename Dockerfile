FROM centos:centos7

RUN yum -y update --nogpgcheck; yum clean all

#Install nginx repo
RUN rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
RUN yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm && \
    yum install -y yum-utils && \
    yum-config-manager --enable remi-php70 && \
    yum -y update
#RUN yum install nginx php php-common php-opcache php-mcrypt php-cli php-gd php-curl php-mysql php-fpm php-mbstring php-pdo php-ldap php-xml php-pear -y
# Install latest version of nginx
ENV nginx_conf /etc/nginx/nginx.conf
RUN yum install -y nginx vim telnet net-tools  wget 

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN mkdir -p /run/php-fpm && \
    chown nginx:nginx /run/php-fpm

RUN mkdir -p /var/lib/php/session && \
    chown nginx:nginx /var/lib/php/session
#Install required php 5.6 packages
#RUN yum install -y php php-fpm --nogpgcheck

RUN yum install nginx php php-common php-opcache php-mcrypt php-cli php-gd php-curl php-mysql php-fpm php-mbstring php-pdo php-ldap php-xml php-pear -y
#Update PHP configs
#ADD ./php.ini /etc/php.ini
#ADD ./www.conf /etc/php-fpm.d/www.conf
#ADD ./index.php  /var/www/html
#RUN sed -i "s/nobody/nginx/g" /etc/php-fpm.d/www.conf
RUN sed -i "s/user = apache/user = nginx/g" /etc/php-fpm.d/www.conf
RUN sed -i "s/group = apache/group = nginx/g" /etc/php-fpm.d/www.conf
RUN sed -i "s/;listen.owner = nobody/listen.owner = nginx/" /etc/php-fpm.d/www.conf
RUN sed -i "s/;listen.group = nobody/listen.group = nginx/" /etc/php-fpm.d/www.conf
RUN sed -i "s/;listen.mode/listen.mode/" /etc/php-fpm.d/www.conf
RUN sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 16M/" /etc/php.ini
RUN sed -i "s/post_max_size = 8M/post_max_size = 16M/" /etc/php.ini
RUN sed -i "s/memory_limit = 128M/memory_limit = 512M/" /etc/php.ini
RUN sed -i "s/user  www-data/user  nginx/" /etc/nginx/nginx.conf
#Update nginx config
ADD ./default.conf /etc/nginx/conf.d/default.conf
ADD nginx.conf ${nginx_conf} 
ADD ./index.php /usr/share/nginx/html/index.php

# Install supervisor to run jobs
RUN yum install -y epel-release 
RUN yum install -y supervisor 

ADD ./supervisord.conf /etc/supervisord.conf
VOLUME ["/var/www/html", "/etc/nginx/ssl"]
#RUN cd /tmp && wget http://download.configserver.com/csf.tgz && tar -xzf csf.tgz  && cd csf && sh install.sh && perl /usr/local/csf/bin/csftest.pl
EXPOSE 80
EXPOSE 443

#Run nginx engine
CMD ["/usr/bin/supervisord","-n","-c","/etc/supervisord.conf"]
