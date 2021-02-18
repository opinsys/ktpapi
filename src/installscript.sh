#!/bin/bash
# parameters
# -t [TARGET_PLATFORM] Testmode
# -m Modify answer download

set -eu

opinsysVersion='0.1'
opinsysInstallDir=/home/digabi/opinsys
opinsysInstallVersionFile="${opinsysInstallDir}/installversion"
cmdInstallDir=/media/usb1/.opinsys

OPTIND=1         # Reset getopts

testmode=0
use_storeanswer_mod=false

while getopts ":t:m" opt; do
    case "$opt" in
        t)
            testmode=1
            target_platform="$OPTARG"
            ;;
        m)
            echo 'Asennetaan vastausten talteenoton muokkaus.'
            use_storeanswer_mod=true
            ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = '--' ] && shift

check_system() {
    if [ $testmode -eq 1 ] ; then
        echo "Ohitetaan palvelimen tarkistus... Asennetaan kuten ${target_platform}."
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
        echo "Palvelimen tuettu versio $systemversion tunnistettu."
    else
        echo "Palvelinta ei tunnistettu."
        echo "Asennus keskeytetään."
        exit 1
    fi
}

report_currently_installed_version() {
    opinsysCurrentVersion=$(cat "$opinsysInstallVersionFile" 2>/dev/null) || true
    if [[ -n "$opinsysCurrentVersion" ]]; then
        echo "Opinsys KTP-API versio ${opinsysCurrentVersion} on jo asennettu."
    fi
}

extract_files() {
    echo 'Puretaan tiedostoja'

    tmpdir=$(mktemp -d /tmp/selfextract.XXXXXX)

    ARCHIVE=$(awk '/^___ARCHIVE_BELOW___/ { print NR + 1; exit 0 }' "$0")

    tail -n+$ARCHIVE $0 | tar -C "$tmpdir" -xz

    (cd "$tmpdir" && ./installer)
    rm -rf "$tmpdir"
}

install_debs() {
    for deb in "$target_platform"/libcurl4_*.deb \
               "$target_platform"/curl_*.deb     \
               "$target_platform"/patch_*.deb; do
        echo "Asennetaan ${deb}."
        sudo dpkg -i "$deb" > /dev/null
    done
}

install_opinsys_dir() {
    mkdir -p "$opinsysInstallDir"
    printf "%s\n" "$opinsysVersion" > "$opinsysInstallVersionFile"
    cp ./apiwatcher.sh   "${opinsysInstallDir}/apiwatcher.sh"
    cp ./timertrigger.sh "${opinsysInstallDir}/timertrigger.sh"
}

install_systemd_timer() {
    if systemctl is-enabled opinsys-ktpapi-timer.timer > /dev/null 2>&1; then
        sudo systemctl stop opinsys-ktpapi-timer.timer
    fi
    sudo cp ./systemd/opinsys-ktpapi-timer* /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable opinsys-ktpapi-timer.{service,timer} > /dev/null
    sudo systemctl start opinsys-ktpapi-timer.timer

    echo "KTP-API-palvelu asennettu."
}

make_cmd_structure() {
    mkdir -p "$cmdInstallDir"
}

install_storeanswer_mod() {
    "$target_platform"/opinsys-download-progress-installer.sh
}

subinstallers() {
    if $use_storeanswer_mod; then
        install_storeanswer_mod
    fi

    for installerscript in "$target_platform"/installer-*.sh; do
        test -x "$installerscript" || continue
        "$installerscript"
    done
}

report_currently_installed_version

echo "Asennetaan Opinsys KTP-API versio ${opinsysVersion}."

check_system
install_debs
install_opinsys_dir
subinstallers
install_systemd_timer
make_cmd_structure

exit 0
