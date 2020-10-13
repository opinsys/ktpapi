#!/bin/bash

check_system() {
    systemversion=`lsblk -n -o LABEL /dev/sda2`
    if [ $systemversion -eq "SERVER2041X" ] ; then

    else 
        echo "Server version not supported"
        exit 1
    fi   
}

extract_files() {
    echo "Extracting files"

    export TMPDIR=`mktemp -d /tmp/selfextract.XXXXXX`

    ARCHIVE=`awk '/^__ARCHIVE_BELOW__/ {print NR + 1; exit 0; }' $0`

    tail -n+$ARCHIVE $0 | tar xzv -C $TMPDIR

    CDIR=`pwd`
    cd $TMPDIR
    ./installer

    cd $CDIR
    rm -rf $TMPDIR
}

check_system



exit 0