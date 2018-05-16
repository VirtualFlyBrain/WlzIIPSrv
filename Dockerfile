FROM httpd:alpine

RUN apk add --update git build-base automake autoconf m4 libtool bison libjpeg-turbo-dev zlib-dev cmake tiff-dev libpng-dev fcgi-dev flex-dev

COPY docker/lighttpd.conf /config/lighttpd.conf

COPY docker/.htpasswd /config/.htpasswd

VOLUME /disk/data/VFB/IMAGE_DATA/

RUN cd /tmp/ \
&& git clone https://github.com/MIRTK/NIFTI.git \
&& cd NIFTI \
&& sed -i 's/csh/ash/' Makefile \
&& make all \
&& cp include/* /usr/include/ \
&& cp lib/* /usr/lib/

RUN cd /tmp/ \
&& git clone https://github.com/ma-tech/Woolz.git \
&& cd Woolz \
&& mkdir -p m4 \
&& libtoolize \
&& aclocal \
&& automake --add-missing \
&& autoreconf -i --force \
&& ./build.sh \
&& ./configure --enable-extff --with-nifti=/tmp/NIFTI/ \
&& make install

RUN cd /tmp/ \
&& git clone https://github.com/VirtualFlyBrain/WlzIIPSrv.git \
&& cd WlzIIPSrv \
&& mkdir -p m4 \
&& libtoolize \
&& aclocal \
&& automake --add-missing \
&& autoreconf -i --force \
&& ./build.sh \
&& ./configure --enable-optimise --enable-static-fcgi --with-wlz-incl=/opt/MouseAtlas/include/ \
--with-wlz-lib=/opt/MouseAtlas/lib/ --with-fcgi-lib=/usr/lib/ --with-fcgi-incl=/usr/include/ \
--with-nifti-incl=/tmp/NIFTI/include/ --with-nifti-lib=/tmp/NIFTI/lib/ \
&& make

RUN sed -i 's|ScriptAlias /cgi-bin/|ScriptAlias /fcgi/|g' /usr/local/apache2/conf/httpd.conf

RUN cp /tmp/WlzIIPSrv/src/wlziipsrv.fcgi /usr/local/apache2/cgi-bin/

RUN sed -i 's|<h1>.*</h1>|<h1>IIP3D</h1>|g' /usr/local/apache2/htdocs/index.html
