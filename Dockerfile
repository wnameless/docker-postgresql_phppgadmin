FROM ubuntu:12.04

MAINTAINER Wei-Ming Wu <wnameless@gmail.com>

RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update

# Install sshd
RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd

# Install expect
RUN apt-get install -y expect

# Set password to 'admin'
RUN echo '#!/usr/bin/expect -f' > passwd.sh; \
	echo "spawn passwd" >> passwd.sh; \
	echo "expect {" >> passwd.sh; \
	echo "password: {send \"admin\r\" ; exp_continue}" >> passwd.sh; \
	echo "eof exit" >> passwd.sh; \
	echo "}" >> passwd.sh
RUN chmod +x passwd.sh
RUN ./passwd.sh; \
	rm passwd.sh

# Install postgresql
RUN apt-get install -y postgresql; \
	su - postgres -c "psql -U postgres -d postgres -c \"alter user postgres with password 'postgres';\""

RUN sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/9.1/main/postgresql.conf
RUN echo 'host all all 0.0.0.0/0 md5' >> /etc/postgresql/9.1/main/pg_hba.conf

RUN apt-get install -y postgresql-contrib

# Set postgresql default encoding to UTF-8
RUN echo "UPDATE pg_database SET datistemplate=FALSE WHERE datname='template1';" > utf8.sql; \
	echo "DROP DATABASE template1;" >> utf8.sql; \
	echo "CREATE DATABASE template1 WITH owner=postgres template=template0 encoding='UTF8';" >> utf8.sql; \
	echo "UPDATE pg_database SET datistemplate=TRUE WHERE datname='template1';" >> utf8.sql

RUN service postgresql start; \
	export PGPASSWORD=postgres; \
	psql -U postgres -h localhost -a -f utf8.sql; \
	rm utf8.sql

# Install Apache
RUN apt-get install -y apache2
# Install php
RUN apt-get install -y php5 libapache2-mod-php5 php5-mcrypt

# Install phppgadmin
RUN apt-get install -y phppgadmin
RUN sed -i "s/# allow from all/allow from all/g" /etc/apache2/conf.d/phppgadmin
RUN sed -i "s/\$conf\['extra_login_security'\] = true;/\$conf\['extra_login_security'\] = false;/g" /etc/phppgadmin/config.inc.php

EXPOSE 22
EXPOSE 80
EXPOSE 5432

CMD service postgresql start; \
	service apache2 start; \
	/usr/sbin/sshd -D
