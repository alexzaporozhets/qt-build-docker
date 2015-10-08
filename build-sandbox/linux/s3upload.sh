#! /bin/bash

CWD=$(pwd)

function onScriptFinished {
    rm -f $CWD/s3uploadcfg.ini
}

trap onScriptFinished EXIT

srcFileName=$1 ; shift
s3BucketName=$1 ; shift
accessKey=$1; shift
secretKey=$1; shift

if [ -z "$srcFileName" -o -z "$s3BucketName" -o -z "$accessKey" -o -z "$secretKey" ] ; then
    echo "Invalid arguments"
    echo "Use: $0 <file> <bucket> <access_key> <secret_key>"
    exit 1
fi

cat > $CWD/s3uploadcfg.ini << EOF
[default]
access_key = $accessKey
secret_key = $secretKey
use_https = True
gpg_passphrase = test
gpg_command = /usr/bin/gpg
EOF

s3CmdOptions=(
    --config=$CWD/s3uploadcfg.ini
    --encrypt
    --force
    --verbose
)

if [ -n "$srcFileName" -a -e "$srcFileName" ] ; then
    dstFileName=$(basename $srcFileName | sed -e 's|-[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*-|-|')

    s3cmd "${s3CmdOptions[@]}"  put --acl-public "$srcFileName" "$s3BucketName/$dstFileName"
    if [ $? -ne 0 ] ; then
        echo "Failed"
        exit 2
    fi

    echo "Success"
    exit 0
else
    echo "File not found: $srcFileName" 
    echo "Failed"
    exit 3
fi
