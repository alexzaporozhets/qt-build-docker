#! /bin/bash -x

BITROCK_DIR="$(find /opt -maxdepth 1 -type d -name installbuilder-* 2> /dev/null)"
BITROCK_BUILDER="$BITROCK_DIR"/bin/builder
BITROCK_CUSTOMIZE="$BITROCK_DIR"/autoupdate/bin/customize.run
BITROCK_UPDATER_BINARY=autoupdate-linux.run
BITROCK_UPDATER="$BITROCK_DIR"/autoupdate/output/"$BITROCK_UPDATER_BINARY"
CWD=$(dirname $(readlink -f $0))

VERSION="0.0.0.0"
DSTDIR=$CWD/qthybrid-app-installer-bitrock

BITROCK_ARCH="linux"
if [ "$(uname -m)" = "x86_64" ] ; then
    BITROCK_ARCH="linux-x64"
fi

# copy Mystaff Client
if [ -e $CWD/install-qthybrid-app/mystaff-client-linux-deployed-$(uname -m).tar.xz ] ; then
    mkdir -p $DSTDIR/mystaff-client
    rm -f $DSTDIR/mystaff-client/*

    mkdir -p $DSTDIR/output
    rm f $DSTDIR/output/*

    tar -C $DSTDIR/ \
        -xvJf $CWD/install-qthybrid-app/mystaff-client-linux-deployed-$(uname -m).tar.xz
    if [ $? -ne 0 ] ; then
        cd $CWD
        exit 3
    fi

    mv $DSTDIR/mystaff-client-$(uname -m)/* \
        $DSTDIR/mystaff-client/
    rm -fr $DSTDIR/mystaff-client-$(uname -m)

    VERSION=$(< $DSTDIR/mystaff-client/version)
else
    exit 4
fi

cd $DSTDIR

"$BITROCK_BUILDER" build $CWD/qthybrid-app-installer-bitrock/install-linux.xml \
     --license $CWD/qthybrid-app-installer-bitrock/license.xml \
     --setvars v3_product_version=$VERSION

if [ -e output/setup-mystaff-client-$VERSION-$BITROCK_ARCH.run ] ; then
    cp -a output/setup-mystaff-client-$VERSION-$BITROCK_ARCH.run \
        output/setup-mystaff-client-latest-linux-$(uname -m).run
    mv -f output/setup-mystaff-client-$VERSION-$BITROCK_ARCH.run \
        output/setup-mystaff-client-$VERSION-linux-$(uname -m).run
fi

#cd $CWD/install-qthybrid-app
#$CWD/qthybrid-app-installer/linux/build.sh

cd $CWD
if [ -e "$DSTDIR/output/setup-mystaff-client-$VERSION-linux-$(uname -m).run" ] ; then
    mkdir -p $CWD/installs/installer-bitrock

    mv -f "$DSTDIR"/output/setup-mystaff-client-*.run \
        $CWD/installs/installer-bitrock/
    cp -a $DSTDIR/mystaff-client/version $CWD/installs/
fi
