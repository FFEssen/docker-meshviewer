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

# update debian and install packages
RUN apt-get update && apt-get -y upgrade && \
    apt-get -y install apache2 curl ruby-sass git && \
    rm /var/www/html/index.html

# Install latest nodejs
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get install -y nodejs

#clone meshviewer
RUN git clone ${git_url} -b ${version} ${build_dir}

#add config
ADD config.json ${run_dir}/config.json

WORKDIR ${build_dir}

#npm and grunt
RUN npm install && \
    npm install bower grunt-cli && \
    node_modules/.bin/bower --allow-root --config.interactive=false install

#build the monster
RUN node_modules/.bin/grunt

#copy meshviewer into run directory
RUN cp -r ${build_dir}/build/* ${run_dir}

#start apache2 and expose port 80
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
EXPOSE 80
