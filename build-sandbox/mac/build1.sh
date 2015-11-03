#! /bin/bash

# Setup Qt5 5.4.2 installtion paths
QTDIR=/opt/Qt5.4.2/5.4/clang_64
export QTDIR
PATH=$QTDIR/bin:/usr/local/bin:$PATH
export PATH

# Copy QtSingleApplication into bundle
copy_OpenCVLibraries()
{
    local BUNDLEDIR=$1; shift
    local BUNDLEBIN="$BUNDLEDIR/Contents/MacOS/$(basename $BUNDLEDIR .app)"
    local LIBNAME
    local LIBNAME1

    mkdir -p "$BUNDLEDIR/Contents/Frameworks"
    
    otool -L "$BUNDLEBIN" | grep 'lib/libopencv_' | awk '{print $1}' | grep '^lib/' | while read F ; do
        LIBNAME=$(basename "$F")
        echo "Copy /usr/local/lib/$LIBNAME to Contents/Frameworks/"
        install_name_tool -change "$F" "@executable_path/../Frameworks/$LIBNAME" "$BUNDLEBIN"
        cp -fL /usr/local/lib/$LIBNAME "$BUNDLEDIR/Contents/Frameworks"
        strip -SXx "$BUNDLEDIR/Contents/Frameworks/$LIBNAME"
    done

    find "$BUNDLEDIR/Contents/Frameworks" -type f -name 'libopencv_*.dylib' | while read F ; do
        LIBNAME=$(basename "$F")
        echo "Update $LIBNAME inside Contents/Frameworks/"
        install_name_tool -id "@executable_path/../Frameworks/$LIBNAME" "$BUNDLEDIR/Contents/Frameworks/$LIBNAME"
        otool -L "$F"  | grep 'lib/libopencv_' | awk '{print $1}' | grep '^lib/' | while read E ; do
            LIBNAME1=$(basename "$E")
            echo "    Update install name for $LIBNAME1"
            install_name_tool -change "$E" "@executable_path/../Frameworks/$LIBNAME1" "$BUNDLEDIR/Contents/Frameworks/$LIBNAME"
        done
    done
}

# Setup build environment
CWD=$(pwd)
SRCDIR=$CWD/qthybrid-app
SRCVER=$(cat $SRCDIR/mystaff-client/version)
TARGET=mystaff-client

mkdir -p $CWD/build-qthybrid-app-$SRCVER
rm -fr $CWD/build-qthybrid-app-$SRCVER/*
cd $CWD/build-qthybrid-app-$SRCVER

# Configure sources for build
qmake -r -spec macx-g++ CONFIG+=x86_64 $SRCDIR/qthybrid-app.pro
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
DSTDIR=$CWD/install-qthybrid-app-$SRCVER/$TARGET-$(uname -m)
mkdir -p $DSTDIR
rm -fr $DSTDIR/*
tar -C $DSTDIR/ -xvzf install-dir-template-macx-$(uname -m).tar.gz
if [ $? -ne 0 ] ; then
    cd $CWD
    exit 3
fi

# copy mystaff client files
cd $CWD/build-qthybrid-app-$SRCVER

cp -a mystaff-client/mystaff.app $DSTDIR/
if [ $? -ne 0 ] ; then
    cd $CWD
    exit 4
fi

find $DSTDIR -type d -name '*.app' -depth 1 | while read BUNDLEDIR ; do
    BUNDLEBIN="$BUNDLEDIR/Contents/MacOS/$(basename $BUNDLEDIR .app)"

    # copy and deploy internal shared libraries
    mkdir -p "$BUNDLEDIR/Contents/Frameworks" 
    otool -L "$BUNDLEBIN" | grep '\slib.*.dylib' | grep -v '/' | awk '{print $1}' | while read F ; do
        LIBNAME=$(basename "$F")
        FILE=$(find $CWD/build-qthybrid-app-$SRCVER -name "$LIBNAME")
        echo "Copy $FILE to Contents/Frameworks/"
        install_name_tool -change "$F" "@executable_path/../Frameworks/$LIBNAME" "$BUNDLEBIN"
        cp -fL $FILE "$BUNDLEDIR/Contents/Frameworks"
        strip -SXx "$BUNDLEDIR/Contents/Frameworks/$LIBNAME"
    done
    
    # Hack for OpenCV libraries and similar
    copy_OpenCVLibraries $BUNDLEDIR
    otool -L "$BUNDLEBIN" | grep '\slib/lib.*\.dylib' | awk '{print $1}' | while read F ; do
        LIBNAME=$(basename "$F")
        FILE=$(find /usr -name $LIBNAME 2> /dev/null)

        echo "Fix path $F -> $FILE"
        install_name_tool -change "$F" "$FILE" "$BUNDLEBIN"
    done
    
    # do macdeployqt
    $QTDIR/bin/macdeployqt $BUNDLEDIR
    if [ $? -ne 0 ] ; then
        cd $CWD
        exit 5
    fi
    # copy_OpenCVLibraries $BUNDLEDIR
done

cd $DSTDIR

tar -C ./mystaff.app/Contents/Resources -xvzf $CWD/mystaff-client-default-ui.tar.gz
if [ $? -ne 0 ] ; then
    cd $CWD
    exit 6
fi

cd $CWD/install-qthybrid-app-$SRCVER

if [ -x $CWD/sign_bundle.sh ] ; then
    clear
    echo
    echo
    echo "****************************************************"
    security  unlock-keychain ~/Library/Keychains/login.keychain || exit 253

    find $DSTDIR -type d -name '*.app' -depth 1 | while read BUNDLEDIR ; do
        $CWD/sign_bundle.sh "$BUNDLEDIR"
    done
fi

rm -f "./mystaff-client-$SRCVER-mac.dmg"
hdiutil create "./mystaff-client-$SRCVER-mac.dmg" -srcfolder "$TARGET-$(uname -m)/" -volname "Mystaff Client"
if [ $? -ne 0 ] ; then
    cd $CWD
    exit 7
fi
cd $CWD
echo "$CWD/install-qthybrid-app-$SRCVER/mystaff-client-$SRCVER-mac.dmg"
exit 0
