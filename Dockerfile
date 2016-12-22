FROM debian:jessie
MAINTAINER Philip Berndroth <philip@freifunk-essen.de>

# Make Debconf less annoying
ENV DEBIAN_FRONTEND noninteractive
ENV DEBIAN_PRIORITY critical
ENV DEBCONF_NOWARNINGS yes

ARG build_dir="/usr/src/meshviewer"
ARG run_dir="/var/www/html/"
ARG git_url="https://github.com/ffnord/meshviewer"
ARG version="v4"
ARG config="https://raw.githubusercontent.com/FFEssen/docker-meshviewer/master/config.json"

# update debian and install packages
RUN apt-get update && apt-get -y upgrade && \
    apt-get -y install apache2 npm ruby-sass git && \
    rm /var/www/html/index.html

#create dirs and add config
RUN mkdir ${build_dir}

ADD ${config} ${run_dir}/config.js

#clone meshviewer
RUN git clone ${git_url} ${version} ${build_dir}

#npm and grunt
RUN cd ${build_dir} && \
    npm install && \
    npm install bower grunt-cli && \
    node_modules/.bin/bower --allow-root --config.interactive=false instal

#build the monster
RUN node_modules/.bin/grunt

#copy meshviewer into run directory
RUN cp -r ${build_dir}/build/* ${run_dir}

#start apache2 and expose port 80
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
EXPOSE 80
