#!/bin/bash
# parameters
# -t [TARGET_PLATFORM] Testmode
# -f Force install
# -u Update only Opinsys ApiWatcher script
# -m Modify answer download

set -eu

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
        target_platform="$OPTARG"
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
        local systemversion=$(lsblk -n -o LABEL /dev/sda2)
        target_platform="$systemversion"

        if [ ! -d "$target_platform" ]; then
            echo "Palvelimen versiota $systemversion ei tueta."
            echo "Asennus keskeytetään."
            exit 1
        fi
        echo "Palvelimen tuettu versio $systemversion tunnistettu"
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

    tmpdir=$(mktemp -d /tmp/selfextract.XXXXXX)

    ARCHIVE=$(awk '/^___ARCHIVE_BELOW___/ { print NR + 1; exit 0 }' "$0")

    tail -n+$ARCHIVE $0 | tar -C "$tmpdir" -xz

    (cd "$tmpdir" && ./installer)
    rm -rf "$tmpdir"
}

install_debs() {
    for libcurlDeb in "$target_platform"/libcurl*.deb "$target_platform"/curl*.deb; do
        echo "Asennetaan $libcurlDeb"
        sudo dpkg -i "$libcurlDeb" > /dev/null
    done
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
    "$target_platform"/opinsys-download-progress-installer.sh
}

subinstallers() {
    [[ -z $modifyAnswerDownload ]] && install_storeanswer_mod
    shopt -s nullglob
    for installerscript in "$target_platform"/installer-*.sh; do
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
