#!/bin/bash
mediadir="/media/usb1"
opinsysdir="$mediadir/.opinsys"
cmd_file="$opinsysdir/cmd"
output_file="$opinsysdir/output"
cookie_file="$opinsysdir/cookie.txt"

# Define function to parse cmd-file
# outputs cmd as $cmd_cmd, $cmd_arg1, $cmd_arg2
read_command() {
    cmd_whole=`cat $cmd_file`
    # split $cmd_whole to words
    IFS=' '
    read -a strarr <<< "$cmd_whole"
    case ${#strarr[*]} in
        0)
            cmd_cmd=""
            cmd_arg1=""
            cmd_arg2=""
        ;;
        1)
            cmd_cmd=${strarr[0]}
            cmd_arg1=""
            cmd_arg2=""
        ;;
        2)
            cmd_cmd=${strarr[0]}
            cmd_arg1=${strarr[1]}
            cmd_arg2=""
        ;;
        *)
            cmd_cmd=${strarr[0]}
            cmd_arg1=${strarr[1]}
            cmd_arg2=${strarr[2]}
        ;;
    esac
}

init_session() {
    curl -b $cookie_file -c $cookie_file 'http://localhost'
}

stamp_execution() {
    local timestamp=$(date +%s)
    echo "$timestamp: $1" > "$opinsysdir/stamp"
}

execute_ping() {
    echo "ping" > $output_file
    stamp_execution "ping"
}

uncrypt_exam_singlekey() {
    local decryptkey=$1
    output_decrypt=`curl 'http://localhost/decrypt-exam' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101 Firefox/68.0' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'Accept-Language: fi-FI,fi;q=0.8,en-US;q=0.5,en;q=0.3' --compressed -H 'Referer: http://localhost/' -H 'Content-Type: application/json; charset=UTF-8' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' -H 'Cookie: supoLang=fin' --data "{\"decryptPassword\":\"$decryptkey\"}"`

}

# Uncrypt exam
# @params $1 filename containing decrypt keystrings
# on false keys lists false keys on global var $falsekeys
uncrypt_exam() {
    local examdecryptfile=`realpath $mediadir/$1`
    while read $line; do 
        uncrypt_exam_singlekey $line
        # TODO handle output
    done < $examdecryptfile
    # TODO handle result

}

loadexam() {
    local examfile=`realpath $mediadir/$1`
    output=`curl -F "examZip=@$examfile" 'http://localhost/load-exam' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101 Firefox/68.0' -H 'Accept: */*' -H 'Accept-Language: fi-FI,fi;q=0.8,en-US;q=0.5,en;q=0.3' --compressed -H 'Referer: http://localhost/' -H 'X-Requested-With: XMLHttpRequest' -b $cookie_file -c $cookie_file`
}

startexam() {
    output_start=`curl 'http://localhost/start-exam' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101 Firefox/68.0' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'Accept-Language: fi-FI,fi;q=0.8,en-US;q=0.5,en;q=0.3' --compressed -H 'Referer: http://localhost/' -H 'Content-Type: application/json; charset=UTF-8' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' -H 'Cookie: supoLang=fin' --data '' -b $cookie_file -c $cookie_file`
}

# Executes loadexam
execute_loadexam() {
    local newexamfile=$1
    local examdecryptfile=$2
    init_session
    loadexam $newexamfile
    # TODO handle output
    uncrypt_exam $examdecryptfile
}

execute_startexam() {
    startexam
    stamp_execution "start"
}

output_error() {
    echo "{error:true, msg:\"$1\", cmd:\"$cmd_cmd\"}" > $output_file
}

read_command

case $cmd_cmd in
    "ping")
        execute_ping
        ;;
    "get-opinsys-info")
        get_script_info
        ;;
    "load-exam")
        execute_loadexam $cmd_arg1 $cmd_arg2
        ;;
    "start-loaded-exam")
        execute_startexam
        ;;
    "start-new-exam")
        execute_startnewexam $cmd_arg1 $cmd_arg2
        ;;
    "get-stats")
        execute_getstats
        ;;
    "shutdown-server")
        stamp_execution "shutdown-server"
        shutdown now
        ;;
    *)
        output_error "Unrecognized command"    
        ;;
    esac    
