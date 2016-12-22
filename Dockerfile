FROM debian:jessie
MAINTAINER Philip Berndroth <philip@freifunk-essen.de>

# Make Debconf less annoying
ENV DEBIAN_FRONTEND noninteractive
ENV DEBIAN_PRIORITY critical
ENV DEBCONF_NOWARNINGS yes

ARG build_dir "/usr/src/meshviewer"
ARG run_dir "/var/www/"
ARG git_url "https://github.com/ffnord/meshviewer"
ARG version "v4"

# update debian and install packages
RUN apt-get update && apt-get -y upgrade \
    apt-apt-get -y install apache2 npm ruby-sass git \
    rm /var/www/index.html

#create dirs and add config
RUN mkdir ${run_dir} \
    mkdir ${build_dir}

ADD config.js ${run_dir}/config.js

#npm and grunt
RUN cd ${build_dir}
    npm install \
    npm install bower grunt-cli
    node_modules/.bin/bower --allow-root --config.interactive=false install

#clone meshviewer
RUN git clone ${git_url} ${version} ${build_dir}

#build the monster
RUN node_modules/.bin/grunt

#copy meshviewer into run directory
RUN cp -r ${build_dir}/build/* ${run_dir}

#start apache2 and expose port 80
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
EXPOSE 80
