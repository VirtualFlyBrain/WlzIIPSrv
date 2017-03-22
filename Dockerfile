FROM jgeusebroek/webdav

RUN apt-get -y update && apt-get -y install git autoconf

COPY docker/lighttpd.conf /config/lighttpd.conf

COPY docker/.htpasswd /config/.htpasswd

RUN cd /tmp/ \
&& git clone https://github.com/ma-tech/Woolz.git \
&& cd woolz \
&& ./build.sh 

RUN cd /tmp/ \
&& git clone https://github.com/VirtualFlyBrain/WlzIIPSrv.git \
&& cd WlzIIPSrv \
&& ./build.sh 
