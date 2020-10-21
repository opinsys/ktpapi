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

Commandfile `.opinsys/cmd` may only contain single command. Result is stored in following files.
* `.opinsys/cmd-stamp`
* `.opinsys/cmd-result`
* `.opinsys/stats` Current stats
* `.opinsys/exams` Currently loaded exams
* `.opinsys/debug-output` Verbose output for debugging purposes

- All commands produce stamp-file

### Load-exam
Loads exam on the server, but does not start it
* Input: `load-exam [filename] [keycodefile]`
    - filename is `.meb`, `.mex` or `.zip` file
    - keycodefile is the file containing keycodes.
        * keycodes are listed on separate lines (separated by `\n`).
    - filenames and paths are represented in relative to `ktp-jako/` folder in Unix format. Whitespace-characters in path or filenames are not supported.
    
* Output: JSON {error, load-exam:{}, decrypt: []}

* If not all exams are decrypted (due to false or unsufficient number of passwords), exampack is not loaded.

### Start-new-exam
Loads a new exam and starts the exam immediatly.
* Input:`start-new-exam [filename] [keycodefile]`
    - See Load-exam for more info
* Output: JSON {error, load-exam:{}, decrypt: []}

### Ping
Command for testing if server API is up.
* Input `ping`
* Output `ping`


### Start-loaded-exam
Starts exam already loaded to the server
* Input `start-loaded-exam`

### Get-Status
Returns status of the surveillance view on the server containing current keycode and students.
* Input `get-status`
* Output:
    - `output`:
    - `stats`: 

### Get-Loaded-Exam
Returns currently loaded exam status and their start time
* Input `get-loaded-exam`
* Output:
    - `output`:
    - `exams`: 

### Get-Opinsys-Info
Returns the version of KTP-API installed to the server
* Input `get-loaded-exam`
* Output: raw version number of KTP-API

### Shutdown-server
Shutdowns the virtual machine server without timeout
* Input `shutdown-server`
* Output: none


## Known issues

- If `.opinsys/cmd` file is deleted, the first command on newly created file does not trigger API handler on virtualized server. The second command will register.