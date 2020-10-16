#!/bin/bash
# parameters
# -t Testmode
# -f Force install 
# -u Update only Opinsys ApiWatcher script

opinsysVersion="v0.1"
opinsysInstallDir=/home/digabi/opinsys
opinsysInstallVersionFile="$opinsysInstallDir/installversion"
cmdInstallDir=/media/usb1/.opinsys

OPTIND=1         # Reset getopts

testmode=0
forceInstall=0
updateOnly=0
# parse options

while getopts ":tfu" opt; do
    case "$opt" in
    t)  testmode=1
        echo "Ohitetaan palvelimen yhteensopivuuden tarkistus"
        # Enable testmode => skip testing if server
        ;;
    f)  forceInstall=1
        echo "Pakotettu päälleasennus"
        # Force install, even if already installed
        ;;
    u)  updateOnly=1
        echo "Päivitetään vain API-skripti"
        ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

check_system() {
    if [ $testmode -eq 1 ] ; then
        echo "Ohitetaan palvelimen tarkistus..."
        return 0
    fi

    if [[ -d /home/digabi && -b /dev/sda2 ]] ; then
        local systemversion=`lsblk -n -o LABEL /dev/sda2`
        if [[ $systemversion -eq "SERVER2041X" ]] ; then
            echo "Palvelimen tuettu versio $systemversion tunnistettu"
            return 0
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
    if [ $forceInstall -eq 1 ] ; then
        echo "Pakotettu uudelleenasennus..."
        return 0
    fi
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

install_debs() {

    sudo dpkg -i ./libcurl.deb
    sudo dpkg -i ./curl.deb
}

install_opinsys_dir() {
    mkdir -p $opinsysInstallDir
    echo $opinsysVersion > $opinsysInstallVersionFile
    cp ./apiwatcher.sh $opinsysInstallDir/apiwatcher.sh
}

install_systemd_watch() {
    systemctl is-enabled opinsys-ktpapi-watcher.path 2> /dev/null
    if [[ $? -eq 0 ]] ; then
        sudo systemctl stop opinsys-ktpapi-watcher.path
    fi
    sudo cp ./systemd/opinsys-* /etc/systemd/system/
    sudo systemctl enable opinsys-ktpapi-watcher.path
    sudo systemctl daemon-reload
    sudo systemctl start opinsys-ktpapi-watcher.path
}

install_systemd_timer() {
    echo "TODO: Install timer"
}

make_cmd_structure() {
    mkdir -p $cmdInstallDir
}

check_system
[[ $updateOnly ]] || check_if_already_installed
[[ $updateOnly ]] || install_debs
install_opinsys_dir
[[ $updateOnly ]] || install_systemd_watch
make_cmd_structure

exit 0