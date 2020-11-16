#!/bin/sh

# Watches whether commandfile has changed

set -eu

cmd_file='/media/usb1/.opinsys/cmd'
lockfile_file='/media/usb1/.opinsys/.cmd-lock'
output_lockfile='/media/usb1/.opinsys/.cmd-in-progress'
stamp_file='/media/usb1/.opinsys/.cmd-timestamp'

handler_script='/home/digabi/opinsys/apiwatcher.sh'

echo 'Opinsys - Timer triggered'

exitstatus=0

(
  # this to prevent concurrent events happening from timer
  if ! flock -nx 9; then
    echo 'Could not get an execution lock'
    exit 1
  fi

  lastchange=$(stat -c %Y "$cmd_file" 2> /dev/null || echo 0)
  lastchangeHandled=$(cat "$stamp_file" 2> /dev/null || echo 0)

  if [ "$lastchange" != "$lastchangeHandled" ]; then
    printf "%s\n" "$lastchange" > "$stamp_file"
    echo 'Opinsys - Change detected, running script'

    "$handler_script" || exitstatus=$?

    echo 'Opinsys - script done, releasing output lockfile'
    rm -f "$output_lockfile"
  fi
) 9> "$lockfile_file"

exit $exitstatus
