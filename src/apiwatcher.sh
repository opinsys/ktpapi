#!/bin/bash
mediadir="/media/usb1"
opinsysdir="$mediadir/.opinsys"
cmd_file="$opinsysdir/cmd"
output_file="$opinsysdir/output"


# Define function to parse cmd-file
# outputs cmd as 
read_command() {
    cmd_whole=`cat $cmd_file`
    cmd_cmd=`echo $cmd_whole | {read a _}`
}

stamp_execution() {
    local timestamp=$(date +%s)
    echo "$timestamp: $1" > "$opinsysdir/stamp"
}

execute_ping() {
    echo "ping" > $output_file
    stamp_execution "ping"
}

# Uncrypt exam
# @params $1 filename containing decrypt keystrings
# on false keys lists false keys on global var $falsekeys
uncrypt_exam() {
    local examdecryptfile=$1
    while read $line; do 

    done < $examdecryptfile
}

# Executes loadexam
execute_loadexam() {
    local newexamfile=$1
    local examdecryptfile=$2

}

read_command

if [ $cmd_cmd -eq "ping" ] ; then
    execute_ping
elif [ $cmd_cmd -eq "load-exam" ] ; then
    execute_loadexam $cmd_arg1 $cmd_arg2
elif [ $cmd_cmd ] ; then
