#! /bin/bash

CWD=$(pwd)
SRCDIR=$CWD/td-qthybrid-app
SRCVER=$(cat $SRCDIR/mystaff-client/version)
TARGET=mystaff-client

mkdir -p $CWD/build-td-qthybrid-app-$SRCVER
rm -fr $CWD/build-td-qthybrid-app-$SRCVER/*
cd $CWD/build-td-qthybrid-app-$SRCVER

# Configure sources for build
qmake -r $SRCDIR/td-qthybrid-app.pro
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
DSTDIR=$CWD/install-td-qthybrid-app-$SRCVER/$TARGET-$(uname -m)
mkdir -p $DSTDIR
rm -fr $DSTDIR/*
tar -C $DSTDIR/ -xvJf install-dir-template-ubuntu14.04-x86_64.tar.xz
if [ $? -ne 0 ] ; then
    cd $CWD
    exit 3
fi

# copy mystaff client files
cd $CWD/build-td-qthybrid-app-$SRCVER

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
cd $CWD/install-td-qthybrid-app-$SRCVER
tar -cvJf mystaff-client-$SRCVER-ubuntu$(lsb_release -rs)-$(uname -m).tar.xz $TARGET-$(uname -m)
if [ $? -ne 0 ] ; then
    cd $CWD
    exit 8
fi

cd $CWD
echo "$CWD/install-td-qthybrid-app-$SRCVER/mystaff-client-$SRCVER-ubuntu$(lsb_release -rs)-$(uname -m).tar.xz"
exit 0
