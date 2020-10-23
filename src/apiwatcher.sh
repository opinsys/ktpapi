#!/bin/bash
mediadir="/media/usb1"
opinsysdir="$mediadir/.opinsys"
cmd_file="$opinsysdir/cmd"
output_file="$opinsysdir/output"
output_exams_file="$opinsysdir/exams"
output_stats_file="$opinsysdir/stats"
output_keycode_file="$opinsysdir/keycode"
cookie_file="$opinsysdir/cookie.txt"
debug_file="$opinsysdir/debug-output"
script_version_file="/home/digabi/opinsys/installversion"

debug_output() {
	echo "$@" >> "$debug_file"
}

output_error() {
    debug_output "ERROR $1, cmd: \"$cmd_cmd\""
    echo "{error:true, msg:\"$1\", cmd:\"$cmd_cmd\"}" > $output_file
}

debug_output "Event triggered"

# Define function to parse cmd-file
# outputs cmd as $cmd_cmd, $cmd_arg1, $cmd_arg2
read_command() {
    if [[ ! -f "$cmd_file" ]]; then
        # cmd_file puuttuu, joten => keskeytetään suoritus
        debug_output "Cmd file not found"
        cmd_cmd=""
        cmd_arg1=""
        cmd_arg2=""
        exit 1
    fi
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
    debug_output "CMD:" $cmd_cmd
}

init_session() {
    debug_output "Session init Curl"
    curl -b $cookie_file -c $cookie_file 'http://localhost'
}

stamp_execution() {
    local timestamp=$(date +%s)
    echo "$timestamp: $1" > "$opinsysdir/stamp"
    debug_output "Stamp $timestamp: $1"
}

write_output() {
    local val=
    for param in "$@"; do
        val+=",${param}"
    done
     cat <<EOF > ${output_file}
{error:false,${val:1},cmd:${cmd_cmd}}
EOF
}

execute_ping() {
    debug_output "Ping.."
    echo "ping" > $output_file
    stamp_execution "ping"
}

uncrypt_exam_singlekey() {
    local decryptkey=$1
    debug_output "Trying to decrypt with \"$1\""
    output_decrypt=`curl 'http://localhost/decrypt-exam' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101 Firefox/68.0' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'Accept-Language: fi-FI,fi;q=0.8,en-US;q=0.5,en;q=0.3' --compressed -H 'Referer: http://localhost/' -H 'Content-Type: application/json; charset=UTF-8' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' -H 'Cookie: supoLang=fin' --data "{\"decryptPassword\":\"$decryptkey\"}"`
    debug_output "DecryptOutput $output_decrypt"
}

# Uncrypt exam
# @params $1 filename containing decrypt keystrings
# on false keys lists false keys on global var $falsekeys
uncrypt_exam() {
    local examdecryptfile=`realpath $mediadir/$1`
    debug_output "Decrypt file \"$examdecryptfile\""
    if [[ ! -f "$examdecryptfile" ]]; then
        # Examfile not found
        output_error "Decryptfile not found"
        exit 1
    fi
    local gathered_output=""
    IFS=
    while IFS= read -r line || [ -n "$line" ]; do 
        # read line by line and continue with the last line even if no \n
        # take away \r characters at the end of lines
        line=${line/%$'\r'/}
        uncrypt_exam_singlekey $line
        gathered_output+=",${output_decrypt}"
        # TODO handle output
    done < "$examdecryptfile"
    output_decrypt="[${gathered_output:1}]"
}

loadexam() {
    local examfile=`realpath $mediadir/$1`
    debug_output "Examfile \"$examfile\""
    if [[ ! -f "$examfile" ]]; then
        # Examfile not found
        output_error "Examfile not found"
        exit 1
    fi
    output_exam=`curl -F "examZip=@$examfile" 'http://localhost/load-exam' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101 Firefox/68.0' -H 'Accept: */*' -H 'Accept-Language: fi-FI,fi;q=0.8,en-US;q=0.5,en;q=0.3' --compressed -H 'Referer: http://localhost/' -H 'X-Requested-With: XMLHttpRequest' -b $cookie_file -c $cookie_file`
    debug_output "CurlOutput $output"
}

startexam() {
    debug_output "Starting exam"
    output_start=`curl 'http://localhost/start-exam' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101 Firefox/68.0' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'Accept-Language: fi-FI,fi;q=0.8,en-US;q=0.5,en;q=0.3' --compressed -H 'Referer: http://localhost/' -H 'Content-Type: application/json; charset=UTF-8' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' -H 'Cookie: supoLang=fin' --data '' -b $cookie_file -c $cookie_file`
    debug_output "Starting output $output_start"
}

# Executes loadexam
execute_loadexam() {
    local newexamfile=$1
    local examdecryptfile=$2
    debug_output "Loading exam \"$1\" \"$2\""
    init_session
    loadexam $newexamfile
    # TODO handle output
    uncrypt_exam $examdecryptfile
    write_output "load-exam:$output_exam" "decrypt:$output_decrypt"
}

execute_startexam() {
    startexam
    stamp_execution "start"
    write_output "start-exam:$output_start"
}

execute_startnewexam() {
    execute_loadexam $1 $2
    startexam
    write_output "load-exam:$output_exam" "decrypt:$output_decrypt" "start-exam:$output_start"
    stamp_execution "start-new-exam"
}

get_script_info() {
    script_version=`cat "${script_version_file}"`
    write_output "script-version:${script_version}"
    stamp_execution "script-version"
}

get_status() {
    output_stats=`curl http://localhost/stats`
}

get_loadedexams() {
    output_exams=`curl http://localhost/exams`
}

execute_getstats() {
    get_status
    echo "${output_stats}" > "$output_stats_file"
    write_output "status:${output_stats}"
}

execute_getexam() {
    get_loadedexams
    echo "${output_exams}" > "$output_exams_file"
    write_output "exams:${output_exams}"
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
    "get-status")
        execute_getstats
        ;;
    "get-exam")
        execute_getexam
        ;;
    "shutdown-server")
        debug_output "Shutdown server"
        stamp_execution "shutdown-server"
        shutdown now
        ;;
    *)
        output_error "Unrecognized command"    
        ;;
    esac    
