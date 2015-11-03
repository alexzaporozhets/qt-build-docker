#! /bin/bash

CWD=$(cd "$(dirname "$0")"; pwd)
DEVELOPER_ID_APPLICATION="Developer ID Application: R Rawson (VAZ876T577)"
SIGNLOG="$SIGNLOG"

invokeCodesign()
{
    local forSigning=$1; shift

    if [ -z "$forSigning" ] ; then 
        return 253
    fi

    codesign -v --force --verify --deep --verbose --sign "$DEVELOPER_ID_APPLICATION" "$forSigning" 2>&1 \
        | sed -e 's|^|*** >   |' \
        | tee -a $SIGNLOG

    return $?
}

doSigning()
{
    local bundlePath=$1 ; shift

    if [ -z "$bundlePath" ] ; then
        return 1
    fi

    echo
    echo
    echo "*** Signing $bundlePath" | tee -a $SIGNLOG

    # Sign frameworks first
    if [ -e "$bundlePath"/Contents/Frameworks ] ; then
        find "$bundlePath"/Contents/Frameworks -type d -name '*.framework' | while read FW ; do
            echo "*** > Signing framework $FW" | tee -a $SIGNLOG
            invokeCodesign "$FW"
        done
    fi

    # Sign dynlibs second
    find "$bundlePath"/Contents -type f -name '*.dylib' | while read DL ; do
        echo "*** > Signing dynlib file $DL" | tee -a $SIGNLOG
        invokeCodesign "$DL"
    done

    # Sign individual files in bundle
    find "$bundlePath"/Contents/MacOS -type f | while read F ; do
        echo "*** > Signing file $F" | tee -a $SIGNLOG
        invokeCodesign "$F"
    done

    echo "*** > Signing entire bundle" | tee -a $SIGNLOG
    invokeCodesign "$bundlePath"

    return $?
}

BUNDLEDIR=$1 ; shift
KEY=$1; shift

if [ -n "$KEY" ] ; then
    DEVELOPER_ID_APPLICATION="$KEY"
fi

if [ -n "$BUNDLEDIR" ] ; then
    SIGNLOG="$CWD/$(basename "$BUNDLEDIR")-codesign.log"
fi

> $SIGNLOG
doSigning "$BUNDLEDIR"
exit $?
