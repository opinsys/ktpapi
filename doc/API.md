# API Description

KTP-API is based on commands written on filesystem level into `.opinsys/cmd` file in `ktp-jako/` folder on ktp

Following commands are supported

* `load-exam [filename] [keycodefile]`
* `start-new-exam [filename] [keycodefile]`
* `start-loaded-exam`
* `change-keycode` (unimplemented)
* `get-status`
* `get-keycode` (unimplemented)
* `get-loaded-exam`
* `get-opinsys-info`
* `get-server-version` (unimplemented)
* `ping`
* `store-exam-results [filename]` (unimplemented)
* `shutdown-server`

Commandfile `.opinsys-cmd` may only contain single command. Result is stored in following files.
* `.opinsys/cmd-stamp`
* `.opinsys/cmd-result`
* `.opinsys/stats` Current stats
* `.opinsys/exams` Currently loaded exams
* `.opinsys/debug-output` Verbose output for debugging purposes

- All commands produce stamp-file

### Load-exam

* Input: `load-exam [filename] [keycodefile]`
    - filename is `.meb`, `.mex` or `.zip` file
    - keycodefile is the file containing keycodes.
        * keycodes are listed on separate lines (separated by `\n`).
    - filenames and paths are represented in relative to `ktp-jako/` folder in Unix format. Whitespace-characters in path or filenames are not supported.
    
* Output: 
* Loads exam, but does not start it.
* If not all exams are decrypted (due to false or unsufficient number of passwords), exampack is not loaded.

### Start-new-exam

* Input:`start new exam [filename] [keycodefile]`
    - See Load-exam for more info
* Output: See load-exam
* Load a new exams and starts the exam. 

### Ping

* Input `ping`
* Output `ping`

Command for testing if server API is up.