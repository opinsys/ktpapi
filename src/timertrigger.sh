#!/bin/bash
# Watches whether commandfile has changed

set -u

cmd_file="/media/usb1/.opinsys/cmd"
stamp_file="/media/usb1/.opinsys/stampf"
lockfile_file="/media/usb1/.opinsys/.cmd-lock"
handler_script="/home/digabi/opinsys/apiwatcher.sh"
output_lockfile="/media/usb1/.opinsys/.cmd-in-progress"
# Max runtime script is allowed prestige is seconds, if 0, concurrence not detected/minded
max_runtime=600

debug_output() {
    echo "$@"
}

debug_output "Opinsys - Timer triggered"

lastchange=`stat -c %Y "${cmd_file}" 2> /dev/null || echo 0`
lastchangeHandled=`cat "${stamp_file}" 2> /dev/null || echo 0`
debug_output "Variables" $lastchange $lastchangeHandled
if [[ ${lastchange} != ${lastchangeHandled} ]]; then
    debug_output "Opinsys - Change detected"
    echo "${lastchange}" > "${stamp_file}"
    # enter lock
    while [[ -f "${lockfile_file}" ]]; do
        debug_output "Opinsys - In lock"
        lockedAt=`cat "${lockfile_file}"`
        if [[ lockedAt+max_runtime -le `date +%s` ]]; then
            debug_output "Override lock"
            break
        fi
        sleep 1
    done
    date +%s > "${lockfile_file}"
    debug_output "Opinsys - Running script"

    "${handler_script}"
    # release locks
    rm -rf "${output_lockfile}"
    rm -rf "${lockfile_file}"
    debug_output "Opinsys - Lock released"

fi