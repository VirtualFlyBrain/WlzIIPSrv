FROM jgeusebroek/webdav

RUN apk add --update git 

RUN apk add --update autoconf

COPY docker/lighttpd.conf /config/lighttpd.conf

COPY docker/.htpasswd /config/.htpasswd

RUN cd /tmp/ \
&& git clone https://github.com/ma-tech/Woolz.git \
&& cd Woolz \
&& ./build.sh 

RUN cd /tmp/ \
&& git clone https://github.com/VirtualFlyBrain/WlzIIPSrv.git \
&& cd WlzIIPSrv \
&& ./build.sh 
