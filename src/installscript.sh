#!/bin/bash
opinsysVersion='v0.1'
opinsysInstallDir='/home/digabi/opinsys'
opinsysInstallVersionFile='$opinsysInstallDir/installversion'

check_system() {
    
    if [[ -d /home/digabi && -b /dev/sda2 ]] ; then
        local systemversion=`lsblk -n -o LABEL /dev/sda2`
        if [[ $systemversion -eq "SERVER2041X" ]] ; then
            echo "Palvelimen tuettu versio $systemversion tunnistettu"
        else 
            echo "Palvelimen versiota $systemversion ei tueta."
            echo "Asennus keskeytetään."
            exit 1
        fi   
    else
        echo "Palvelinta ei tunnistettu."
        echo "Asennus keskeytetään."
        exit 1
    fi
}

check_if_already_installed() {
    [[ -f "$opinsysInstallVersionFile" ]] && { echo "Opinsys KTP-API on jo asennettu" ; exit 2 ; }
}

extract_files() {
    echo "Extracting files"

    export TMPDIR=`mktemp -d /tmp/selfextract.XXXXXX`

    ARCHIVE=`awk '/^___ARCHIVE_BELOW___/ {print NR + 1; exit 0; }' $0`

    tail -n+$ARCHIVE $0 | tar xzv -C $TMPDIR

    CDIR=`pwd`
    cd $TMPDIR
    ./installer

    cd $CDIR
    rm -rf $TMPDIR
}

install_opinsys_dir() {
    mkdir -p $opinsysInstallDir
    echo $opinsysVersion > $opinsysInstallVersionFile
    cp ./apiwatcher.sh $opinsysInstallDir/apiwatcher.sh
}

install_systemd() {
    cp ./systemd/opinsys-* /etc/systemd/system/
    sudo systemctl enable opinsys-ktpapi-watcher.path
    sudo systemctl start opinsys-ktpapi-watcher.path
}

check_system
check_if_already_installed
install_opinsys_dir
install_systemd

exit 0