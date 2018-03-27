FROM jgeusebroek/webdav

RUN apk add --update git build-base automake autoconf m4 libtool bison

COPY docker/lighttpd.conf /config/lighttpd.conf

COPY docker/.htpasswd /config/.htpasswd

RUN cd /tmp/ \
&& git clone https://github.com/ma-tech/Woolz.git \
&& cd Woolz \
&& mkdir -p m4 \
&& autoreconf -i --force \
&& ./build.sh 

RUN cd /tmp/ \
&& git clone https://github.com/VirtualFlyBrain/WlzIIPSrv.git \
&& cd WlzIIPSrv \
&& mkdir -p m4 \
&& autoreconf -i --force \
&& ./build.sh 
