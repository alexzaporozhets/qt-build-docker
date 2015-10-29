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

if [ -e install-dir-template-linux-x86_64.tar.xz ] ; then
    tar -C $DSTDIR/ -xvJf install-dir-template-linux-x86_64.tar.xz
    if [ $? -ne 0 ] ; then
        cd $CWD
        exit 3
    fi
fi

# copy mystaff client files
cd $CWD/build-qthybrid-app

# Copy SQLCipher plugin
mkdir -p $DSTDIR/sqldrivers
find . -type f -name 'libqsqlcipher.so' -exec cp -a {} $DSTDIR/sqldrivers \;
if [ $? -ne 0 ] ; then
    cd $CWD
    exit 4
fi

# Copy Version file
cp -a $SRCDIR/mystaff-client/version $DSTDIR/version
if [ $? -ne 0 ] ; then
    cd $CWD
    exit 5
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
tar -cvJf mystaff-client-linux-$(uname -m).tar.xz $TARGET-$(uname -m)
if [ $? -ne 0 ] ; then
    cd $CWD
    exit 8
fi

set -x
cd $CWD

# Copy Qt5 runtime
if [ -e install-dir-qt5runtime-linux-$(uname -m).tar.xz ] ; then
    tar -C $DSTDIR/ -xvJf install-dir-qt5runtime-linux-$(uname -m).tar.xz
    if [ $? -ne 0 ] ; then
        cd $CWD
        exit 3
    fi

    # Pack deployed mystaff client 
    cd $CWD/install-qthybrid-app
    tar -cvJf mystaff-client-linux-deployed-$(uname -m).tar.xz $TARGET-$(uname -m)
    if [ $? -ne 0 ] ; then
        cd $CWD
        exit 8
    fi

    echo "$CWD/install-qthybrid-app/mystaff-client-linux-deployed-$(uname -m).tar.xz"
else
    echo "$CWD/install-qthybrid-app/mystaff-client-linux-$(uname -m).tar.xz"
fi

set +x
cd $CWD
exit 0
