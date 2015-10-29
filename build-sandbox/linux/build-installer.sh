#! /bin/bash -x

QTIFWDIR="$HOME/Qt/QtIFW2.0.1"
CWD=$(dirname $(readlink -f $0))

DSTDIR=$CWD/qthybrid-app-installer/linux/packages

# copy Mystaff Client  
if [ -e $CWD/install-qthybrid-app/mystaff-client-linux-$(uname -m).tar.xz ] ; then
    rm -f $DSTDIR/com.mystaff.mystaffclient/data/*
    
    tar -C $DSTDIR/com.mystaff.mystaffclient \
        -xvJf $CWD/install-qthybrid-app/mystaff-client-linux-$(uname -m).tar.xz
    if [ $? -ne 0 ] ; then
        cd $CWD
        exit 3
    fi
    
    mv $DSTDIR/com.mystaff.mystaffclient/mystaff-client-$(uname -m)/* \
        $DSTDIR/com.mystaff.mystaffclient/data/
    rm -fr $DSTDIR/com.mystaff.mystaffclient/mystaff-client-$(uname -m)
fi

cd $CWD/install-qthybrid-app
$CWD/qthybrid-app-installer/linux/build.sh
cd $CWD

# /home/local/build-sandbox/install-qthybrid-app
# mystaff-client-linux-deployed-x86_64.tar.xz
# mystaff-client-linux-x86_64.tar.xz
# mystaff-client-x86_64
# /home/local/build-sandbox/qthybrid-app-installer/linux/packages/io.qt.qt5runtime/data
# /home/local/build-sandbox/qthybrid-app-installer/linux/packages/com.mystaff.mystaffclient
