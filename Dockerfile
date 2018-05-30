FROM httpd:alpine

RUN apk add --update git build-base automake autoconf m4 libtool bison cmake flex zlib-dev nasm

VOLUME /disk/data/VFB/IMAGE_DATA/
ENV MA=/opt/MouseAtlas
ENV PATH=/opt/MouseAtlas/bin:$PATH
ENV LD_LIBRARY_PATH=/opt/MouseAtlas/lib:$LD_LIBRARY_PATH
ENV LD_RUN_PATH=/opt/MouseAtlas/lib:$LD_RUN_PATH

RUN cd /tmp/ \
&& git clone https://github.com/ma-tech/External.git

RUN cd /tmp/External/ \
&& cd Fcgi/ \
&& tar -zxf fcgi-2.4.0.tar.gz \
&& patch -p0 < fcgi-2.4.0-patch-01 \
&& cd fcgi-2.4.0 \
&& ./configure --prefix=$MA --enable-static --disable-shared \
&& make \
&& make install

RUN cd /tmp/External/ \
&& cd Log4Cpp \
&& rm -rf log4cpp-1.0 \
&& tar -zxf log4cpp-1.0.tar.gz \
&& patch -p0 < log4cpp-1.0.patch \
&& cd log4cpp-1.0 \
&& ./configure --prefix $MA --disable-shared --enable-static --with-pic \
&& make \
&& make install

RUN cd /tmp/External/ \
&& cd PNG \
&& rm -rf libpng-1.6.29 \
&& tar -zxf libpng-1.6.29.tar.gz \
&& cd libpng-1.6.29 \
&& ./configure --prefix $MA --disable-shared --enable-static --with-pic \
&& make \
&& make install

RUN cd /tmp/External/ \
&& cd Jpeg \
&& rm -rf libjpeg-turbo-1.5.1 \
&& tar -zxf libjpeg-turbo-1.5.1.tar.gz \
&& cd libjpeg-turbo-1.5.1 \
&& autoreconf -fi \
&& ./configure --prefix $MA --disable-shared --enable-static --with-jpeg7 --with-pic \
&& make \
&& make install

RUN cd /tmp/External/ \
&& cd Tiff \
&& rm -rf tiff-4.0.8 \
&& tar -zxf tiff-4.0.8.tar.gz \
&& cd tiff-4.0.8 \
&& ./configure --prefix=$MA --disable-shared --enable-static --with-pic --with-jpeg-include-dir=$MA/include --with-jpeg-lib-dir==$MA/lib \
&& make \
&& make install

RUN cd /tmp/External/ \
&& cd NIfTI \
&& tar -zxf nifticlib-2.0.0.tar.gz \
&& cmake nifticlib-2.0.0 \
&& make \
&& make install

RUN cd /tmp/ \
&& git clone https://github.com/ma-tech/Woolz.git \
&& cd Woolz \
&& mkdir -p m4 \
&& libtoolize \
&& aclocal \
&& automake --add-missing \
&& autoreconf -i --force \
&& ./build.sh \
&& ./configure --prefix=$MA --enable-optimise --enable-extff --with-jpeg=$MA --with-tiff=$MA --with-nifti=/usr/local/ \
&& make \
&& make install

RUN cd /tmp/ \
&& git clone https://github.com/ma-tech/WlzIIPSrv.git \
&& cd WlzIIPSrv \
&& git fetch --all --tags --prune \ 
&& git checkout tags/version-1.1.9 -b version-1.1.9 \
&& mkdir -p m4 \
&& libtoolize \
&& aclocal \
&& automake --add-missing \
&& autoreconf -i --force \
&& ./build.sh \
&& ./configure --prefix=$MA --enable-optimise --with-wlz-incl=/opt/MouseAtlas/include/ \
--with-wlz-lib=/opt/MouseAtlas/lib/ --with-fcgi-lib=/opt/MouseAtlas/lib/ --with-fcgi-incl=/opt/MouseAtlas/include/ \
--with-nifti-incl=/usr/local/include/ --with-nifti-lib=/usr/local/lib/ --with-jpeg-includes=/opt/MouseAtlas/include/ --with-jpeg-libraries=/opt/MouseAtlas/lib/ --with-tiff-includes=/opt/MouseAtlas/include/ --with-tiff-libraries=/opt/MouseAtlas/lib/ --with-png-includes=/opt/MouseAtlas/include/ --with-png-libraries=/opt/MouseAtlas/lib/ \
&& make

RUN cp /usr/lib/apache2/mod_fcgid.so /usr/local/apache2/modules/mod_fcgid.so

RUN sed -i 's|ScriptAlias /cgi-bin/|ScriptAlias /fcgi/ "/usr/local/apache2/fcgi/"\nScriptAlias /cgi-bin/|g' /usr/local/apache2/conf/httpd.conf

RUN sed -i 's|#AddHandler cgi-script .cgi|LoadModule fcgid_module /modules/mod_fcgid.so\nAddHandler cgi-script .cgi\nFcgidBusyTimeout 3600\nAddHandler fcgid-script .fcgi|g' /usr/local/apache2/conf/httpd.conf

RUN mkdir -p /usr/local/apache2/fcgi/ && cp /tmp/WlzIIPSrv/src/wlziipsrv.fcgi /usr/local/apache2/fcgi/ && chmod -R 777 /usr/local/apache2/fcgi

RUN sed -i 's|# "/usr/local/apache2/cgi-bin"|<Directory /disk/data/apache/fcgi/>\n    SetHandler fcgid-script\n    AllowOverride AuthConfig FileInfo Indexes\n    Options FollowSymLinks ExecCGI MultiViews\n    Order allow,deny\n    Require all granted\n</Directory>\n# "/usr/local/apache2/cgi-bin"|g' /usr/local/apache2/conf/httpd.conf 

RUN echo -e "    Header set Access-Control-Allow-Origin \"*\"\n    Header set Cache-Control \"public\"\n    Header unset Pragma\n\n" >> /usr/local/apache2/conf/httpd.conf 

# RUN echo -e "## IIP Server settings:\n  DefaultInitEnv LOGFILE \"/tmp/wlziip.log\"\n  DefaultInitEnv VERBOSITY \"1\"\n  DefaultInitEnv JPEG_QUALITY \"75\"\n  DefaultInitEnv MAX_IMAGE_CACHE_SIZE \"10\"\n  DefaultInitEnv MAX_CVT \"5000\"\n  DefaultInitEnv WLZ_TILE_WIDTH \"1025\"\n  DefaultInitEnv WLZ_TILE_HEIGHT \"1025\"\n  DefaultInitEnv MAX_WLZOBJ_CACHE_SIZE \"1024\"\n  DefaultInitEnv MAX_WLZOBJ_CACHE_COUNT \"100\"\n" >> /usr/local/apache2/conf/httpd.conf 

RUN sed -i 's|<h1>.*</h1>|<h1>IIP3D</h1>|g' /usr/local/apache2/htdocs/index.html

RUN echo "Built $(date +%y-%m-%d-%H-%M-%S)" >> /tmp/wlziip.log
