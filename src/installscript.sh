#!/bin/bash
# parameters
# -t [TARGET_PLATFORM] Testmode
# -f Force install
# -u Update only Opinsys ApiWatcher script
# -m Modify answer download

opinsysVersion="v0.1"
opinsysInstallDir=/home/digabi/opinsys
opinsysInstallVersionFile="$opinsysInstallDir/installversion"
cmdInstallDir=/media/usb1/.opinsys

OPTIND=1         # Reset getopts

testmode=0
forceInstall=0
updateOnly=0
modifyAnswerDownload=0
# parse options

while getopts ":t:fum" opt; do
    case "$opt" in
    t)  testmode=1
        target_platform=$OPTARG
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
    m) modifyAnswerDownload=1
        echo "Asennetaan vastausten talteenoton muokkaus"
        ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

check_system() {
    if [ $testmode -eq 1 ] ; then
        echo "Ohitetaan palvelimen tarkistus... Asennetaan kuten $target_platform"
        return 0
    fi

    if [[ -d /home/digabi && -b /dev/sda2 ]] ; then
        local systemversion=`lsblk -n -o LABEL /dev/sda2`

        case $systemversion in
            SERVER2003K)
                target_platform=$systemversion
                target_platform_dir=./$target_platform
                target_platform_base=.
                target_platform_deb_dir=./$target_platform
                ;;
            SERVER2041X)
                target_platform=$systemversion
                target_platform_dir=./$target_platform
                target_platform_base=.
                target_platform_deb_dir=./$target_platform
                ;;
            *)
                echo "Palvelimen versiota $systemversion ei tueta."
                echo "Asennus keskeytetään."
                exit 1
                ;;
            esac
        echo "Palvelimen tuettu versio $systemversion tunnistettu"
        return 0;
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
    for libcurlDeb in "$target_platform_deb_dir"/libcurl*.deb "$target_platform_deb_dir"/curl*.deb; do
        echo "Asennetaan $libcurlDeb"
        sudo dpkg -i "$libcurlDeb"
    done
#    sudo dpkg -i "$target_platform_deb_dir"/libcurl*.deb
#    sudo dpkg -i "$target_platform_deb_dir"/curl*.deb

}

install_opinsys_dir() {
    mkdir -p $opinsysInstallDir
    echo $opinsysVersion > $opinsysInstallVersionFile
    cp ./apiwatcher.sh $opinsysInstallDir/apiwatcher.sh
    cp ./timertrigger.sh $opinsysInstallDir/timertrigger.sh
}

uninstall_systemd_watch() {
    # do not install watch service
    systemctl is-enabled opinsys-ktpapi-watcher.path 2> /dev/null
    if [[ $? -eq 0 ]] ; then
        sudo systemctl stop opinsys-ktpapi-watcher.path
        sudo systemctl stop opinsys-ktpapi-watcher.service
        sudo systemctl disable opinsys-ktpapi-watcher.path
        sudo systemctl disable opinsys-ktpapi-watcher.service
        sudo rm /etc/systemd/system/opinsys-ktpapi-watcher.path
        sudo rm /etc/systemd/system/opinsys-ktpapi-watcher.service
        sudo systemctl daemon-reload
    fi
}

install_systemd_timer() {
    systemctl is-enabled opinsys-ktpapi-timer.timer 2> /dev/null
    if [[ $? -eq 0 ]] ; then
        sudo systemctl stop opinsys-ktpapi-timer.timer
    fi
    sudo cp ./systemd/opinsys-ktpapi-timer* /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable opinsys-ktpapi-timer.{service,timer}
    sudo systemctl start opinsys-ktpapi-timer.timer
    echo "KTP-API-palvelu asennettu"
}

make_cmd_structure() {
    mkdir -p $cmdInstallDir
}

install_storeanswer_mod() {
    "$target_platform_dir"/opinsys-download-progress-installer.sh
}

subinstallers() {
    [[ -z $modifyAnswerDownload ]] && install_storeanswer_mod
    shopt -s nullglob 
    for installerscript in "$target_platform_dir"/installer-*.sh; do
        $installerscript
    done
}

check_system
[[ $updateOnly -eq 1 ]] || check_if_already_installed
[[ $updateOnly -eq 1 ]] || install_debs
install_opinsys_dir
subinstallers
[[ $updateOnly -eq 1 ]] || install_systemd_timer
[[ $updateOnly -eq 1 ]] || uninstall_systemd_watch
make_cmd_structure

exit 0
