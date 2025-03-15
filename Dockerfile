# Use Ubuntu 24.04 as the base image
FROM ubuntu:24.04

# Set the environment variable to avoid interactive prompts during the install
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages for Apache, PHP, WordPress, and Tomcat
RUN apt-get update && \
    apt-get -q -y install apache2 \
    php7.4 \
    php7.4-fpm \
    php7.4-mysql \
    libapache2-mod-php7.4 \
    openjdk-17-jdk \
    wget \
    tar \
    && apt-get clean

# Install and set up Tomcat
RUN wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.56/bin/apache-tomcat-9.0.56.tar.gz -P /tmp && \
    tar xzvf /tmp/apache-tomcat-9.0.56.tar.gz -C /opt && \
    ln -s /opt/apache-tomcat-9.0.56 /opt/tomcat

# Expose ports for Apache (80) and Tomcat (8080)
EXPOSE 80 8080

# Set up WordPress with Apache
ADD http://wordpress.org/latest.tar.gz /tmp
RUN tar xzvf /tmp/latest.tar.gz -C /tmp \
    && cp -R /tmp/wordpress/* /var/www/html \
    && rm /var/www/html/index.html \
    && chown -R www-data:www-data /var/www/html

# Copy the WAR file for the Java application to Tomcat webapps folder
COPY target/java-web-app-1.0-SNAPSHOT.war /opt/tomcat/webapps/ROOT.war

# Start both Apache and Tomcat together
CMD /usr/sbin/apache2ctl -D FOREGROUND & \
    /opt/tomcat/bin/catalina.sh run
