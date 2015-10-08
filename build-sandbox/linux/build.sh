#! /bin/bash

CWD=$(pwd)
SRCDIR=$CWD/qthybrid-app
SRCVER=$(cat $SRCDIR/mystaff-client/version)
TARGET=mystaff-client

mkdir -p $CWD/build-qthybrid-app
rm -fr $CWD/build-qthybrid-app/*
cd $CWD/build-qthybrid-app

# Configure sources for build
qmake -r $SRCDIR/qthybrid-app.pro
if [ $? -ne 0 ] ; then
    cd $CWD
    exit 1
fi

# make 
make
if [ $? -ne 0 ] ; then
    cd $CWD
    exit 2
fi

cd $CWD

# Prepare installation directory
DSTDIR=$CWD/install-qthybrid-app/$TARGET-$(uname -m)
mkdir -p $DSTDIR
rm -fr $DSTDIR/*
tar -C $DSTDIR/ -xvJf install-dir-template-ubuntu14.04-x86_64.tar.xz
if [ $? -ne 0 ] ; then
    cd $CWD
    exit 3
fi

# copy mystaff client files
cd $CWD/build-qthybrid-app

# Copy SQLCipher plugin
find . -type f -name 'libqsqlcipher.so' -exec cp -a {} $DSTDIR/sqldrivers \;
if [ $? -ne 0 ] ; then
    cd $CWD
    exit 4
fi

# Copy mystaff client executible file
cp -a mystaff-client/mystaff $DSTDIR/mystaff.bin
if [ $? -ne 0 ] ; then
    cd $CWD
    exit 5
fi

# Remove rpath frommystaff client binary
chrpath -d $DSTDIR/mystaff.bin
if [ $? -ne 0 ] ; then
    cd $CWD
    exit 6
fi

# Copy internal libraries which are required for mystaff client
ldd $DSTDIR/mystaff.bin | grep 'not found' | awk '{print $1}' | while read N ; do
    find . -name "$N" -exec cp {} $DSTDIR \;
    if [ $? -ne 0 ] ; then
        cd $CWD
        exit 7
    fi
done

# Pack mystaff client 
cd $CWD/install-qthybrid-app
tar -cvJf mystaff-client-ubuntu$(lsb_release -rs)-$(uname -m).tar.xz $TARGET-$(uname -m)
if [ $? -ne 0 ] ; then
    cd $CWD
    exit 8
fi

cd $CWD
echo "$CWD/install-qthybrid-app/mystaff-client-ubuntu$(lsb_release -rs)-$(uname -m).tar.xz"
exit 0
