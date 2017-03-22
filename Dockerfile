FROM jgeusebroek/webdav

COPY docker/lighttpd.conf /config/lighttpd.conf

COPY docker/.htpasswd /config/.htpasswd

