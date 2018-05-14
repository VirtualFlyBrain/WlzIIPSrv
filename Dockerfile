FROM jgeusebroek/webdav

RUN apk add --update git build-base automake autoconf m4 libtool bison libjpeg-turbo-dev zlib-dev cmake tiff-dev libpng-dev fcgi-dev flex-dev

COPY docker/lighttpd.conf /config/lighttpd.conf

COPY docker/.htpasswd /config/.htpasswd

RUN cd /tmp/ \
&& git clone https://github.com/MIRTK/NIFTI.git \
&& cd NIFTI \
&& sed -i 's/csh/ash/' Makefile \
&& make all

RUN cd /tmp/ \
&& git clone https://github.com/ma-tech/Woolz.git \
&& cd Woolz \
&& mkdir -p m4 \
&& automake --add-missing \
&& autoreconf -i --force \
&& ./build.sh \
&& ./configure --enable-extff --with-nifti=/tmp/NIFTI/ \
&& make install

RUN cd /tmp/ \
&& git clone https://github.com/VirtualFlyBrain/WlzIIPSrv.git \
&& cd WlzIIPSrv \
&& mkdir -p m4 \
&& autoreconf -i --force \
&& ./build.sh \
&& ./configure --with-wlz-incl=/opt/MouseAtlas/include/ --with-wlz-lib=/opt/MouseAtlas/lib/ \
&& make
