#!/bin/bash
# Watches whether commandfile has changed
cmd_file="/media/usb1/.opinsys/cmd"
stamp_file="/media/usb1/.opinsys/stampf"
lockfile_file="/media/usb1/.opinsys/lock"
handler_script="/home/digabi/opinsys/apiwatcher.sh"
allowConcurrent=true
lastchange=`stat -c %Y "${cmd_file}"`||0
lastchangeHandled=`cat "${stamp_file}"`||0
if [[ ${lastchange} -ne ${lastchangeHandled} ]]; then
    echo "${lastchangeHandled}" > "${stamp_file}"
    "${handler_script}"
fi
