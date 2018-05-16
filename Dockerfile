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

RUN sed -i 's|ScriptAlias /cgi-bin/|ScriptAlias /fcgi/ "/usr/local/apache2/fcgi/"\nScriptAlias /cgi-bin/|g' /usr/local/apache2/conf/httpd.conf

RUN sed -i 's|#AddHandler cgi-script .cgi|AddHandler cgi-script .cgi\nAddHandler fcgid-script fcg fcgi|g' /usr/local/apache2/conf/httpd.conf

RUN mkdir -p /usr/local/apache2/fcgi/ && cp /tmp/WlzIIPSrv/src/wlziipsrv.fcgi /usr/local/apache2/fcgi/ && chmod -R 777 /usr/local/apache2/fcgi

RUN sed -i 's|# "/usr/local/apache2/cgi-bin"|<Directory /disk/data/apache/fcgi/>\n    SetHandler fcgid-script\n    AllowOverride AuthConfig FileInfo Indexes\n    Options FollowSymLinks ExecCGI MultiViews\n</Directory>\n# "/usr/local/apache2/cgi-bin"|g' /usr/local/apache2/conf/httpd.conf 

RUN echo -e "    Header set Access-Control-Allow-Origin \"*\"\n    Header set Cache-Control \"public\"\n    Header unset Pragma\n\n" >> /usr/local/apache2/conf/httpd.conf 

RUN echo -e "## IIP Server settings:\n  DefaultInitEnv LOGFILE \"/tmp/wlziip.log\"\n  DefaultInitEnv VERBOSITY \"1\"\n  DefaultInitEnv JPEG_QUALITY \"75\"\n  DefaultInitEnv MAX_IMAGE_CACHE_SIZE \"10\"\n  DefaultInitEnv MAX_CVT \"5000\"\n  DefaultInitEnv WLZ_TILE_WIDTH \"1025\"\n  DefaultInitEnv WLZ_TILE_HEIGHT \"1025\"\n  DefaultInitEnv MAX_WLZOBJ_CACHE_SIZE \"1024\"\n  DefaultInitEnv MAX_WLZOBJ_CACHE_COUNT \"100\"\n" >> /usr/local/apache2/conf/httpd.conf 

RUN sed -i 's|<h1>.*</h1>|<h1>IIP3D</h1>|g' /usr/local/apache2/htdocs/index.html

RUN echo "Built $(date +%y-%m-%d-%H-%M-%S)" >> /tmp/wlziip.log
