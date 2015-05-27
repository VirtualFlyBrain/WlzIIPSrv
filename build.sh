#!/bin/sh
# This script will configure and build the Woolz IIP Server. Uncomment
# the appropriate configure command lines for the build you want. The
# easiest way to use this script is probably to copy it to mybuild.sh and
# the edit that script.

set -x
# In most cases a simple autoreconf should be sufficient
# autoreconf
# If you hit problems with missing files or libtool use the following
# autoreconf
autoreconf -i --force

#export MA=$HOME
#export MA=$HOME/MouseAtlas/Build/
# export MA=/opt/MouseAtlas
export MA=/disk/data/VFBTools/Woolz.compiled

# Set C and C++ flags
#export CFLAGS=-g
export CFLAGS='-O3 -mfpmath=sse'
#export CXXFLAGS=-g
export CXXFLAGS='-O3 -mfpmath=sse'

# Configure
./configure --with-fcgi-incl=/opt/fcgi/include --with-fcgi-lib=/opt/fcgi/lib \
            --with-jpeg-incl=$MA/include -with-jpeg-lib=$MA/lib \
	    --with-tiff-incl=$MA/include -with-tiff-lib=$MA/lib \
            --with-wlz-incl=$MA/include --with-wlz-lib=$MA/lib \
	    --enable-openmp
	    
# ./configure --with-fcgi-incl=/disk/data/VFBTools/WlzIIPSrv/fcgi/include --with-fcgi-lib=/disk/data/VFBTools/WlzIIPSrv/fcgi/libfcgi \
# 	    --with-jpeg-incl=$MA/include -with-jpeg-lib=$MA/lib \
# 	    --with-tiff-incl=$MA/include -with-tiff-lib=$MA/lib \
#             --with-wlz-incl=$MA/include --with-wlz-lib=$MA/lib \
# 	    --with-log4cpp-incl=$MA/include --with-log4cpp-lib=$MA/lib \
#             --enable-static --with-pic \
# 	    --enable-openmp

