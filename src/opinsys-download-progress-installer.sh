#!/bin/bash

# NOTICE: This is a template file that needs to be
# altered for each server version

downloadProgressTarget="/usr/local/bin/digabi-download-progress"
downloadProgressOriginal="${downloadProgressTarget}-original"
scriptFile="./opinsys-download-progress"
# Following numbers are row count where mod is entered
headCount="7"
tailCount="+8"

if [[ ! -f "${scriptFile}" ]]; then 
    echo "Vastausten talteenoton mahdollistavaa muokkausta ei tehty - asennustiedostoa ei löytynyt."
    exit 1
fi

# following is the expected digabi-download-progress size from server
expectedTargetSize=2111
targetSize=`stat -c %s "${downloadProgressTarget}"`

# Make sure that target equals e
if [[ $targetSize -eq $expectedTargetSize ]]; then
    # target is original, installation can proceed
    # make a backup
    sudo cp "${downloadProgressTarget}" "${downloadProgressOriginal}"
    headPart=`head -n $headCount "${downloadProgressTarget}"`
    tailPart=`tail -n $tailCount "${downloadProgressTarget}"`
    permissions=`stat -c '%a' "${downloadProgressTarget}"`
    sudo echo "$headPart" > "${downloadProgressTarget}"
    sudo cat "${scriptFile}" >> "${downloadProgressTarget}"
    sudo echo "$tailPart" >> "${downloadProgressTarget}"
    sudo chmod ${permissions} "${downloadProgressTarget}"
else
    # target is not confirmed
    echo "Vastausten talteenoton mahdollistavaa muokkausta ei tehty."
    exit 1
fi