# API Description

KTP-API is based on commands written on filesystem level into `.opinsys/cmd` file in `ktp-jako/` folder on ktp

Following commands are supported

* `load-exam [filename] [keycodefile]`
* `start-new-exam [filename] [keycodefile]`
* `start-loaded-exam`
* `change-keycode`
* `get-status`
* `get-exam`
* `get-script-info`
* `get-server-version` (unimplemented)
* `ping`
* `shutdown-server`
* `store-exam-results`
* `update`

Commandfile `.opinsys/cmd` may only contain single command. Command file is checked in 5 sec intervals (interval length is not quaranteed).
Result is stored in following files.
* `.opinsys/cmd-stamp`
* `.opinsys/cmd-result`
* `.opinsys/stats` Current stats
* `.opinsys/exams` Currently loaded exams
* `.opinsys/debug-output` Verbose output for debugging purposes

Lockfiles
*   `.opinsys/.cmd-in-progress`file is deleted immediatly after execution is finished, undependent of whether cmd has finished with error or not. This allows external API user to create file and wait for execution start and exection to finish before checking the results by checking whether file exist.
*   `.opinsys.cmd-lock` internal lock file contains current commands execution start timestamp. Following command execution does not start before this file is deleted or contents timestamp older than 10 minutes.
- All commands produce stamp-file


### Load-exam
Loads exam on the server, but does not start it
* Input: `load-exam [filename] [keycodefile]`
    - filename is `.meb`, `.mex` or `.zip` file
    - keycodefile is the file containing keycodes.
        * keycodes are listed on separate lines (separated by `\n`).
    - filenames and paths are represented in relative to `ktp-jako/` folder in Unix format. Whitespace-characters in path or filenames are not supported.
    
* Output: JSON `{"error":true/false, "load-exam":{...}, "decrypt": [], "cmd":"load-exam"}`
```json
{"error":false,"load-exam":["exam_koetiedosto1_mex.meb","exam_koetiedosto2.meb"],"decrypt":[{"mebs":["exam_koetiedosto1_mex.meb"],"password":"varmasti munaus sovittaa optio","wrongPassword":false},{"mebs":["exam_koetiedosto1_mex.meb","exam_koetiedosto2.meb"],"password":"konttaus urjeta laskelma ilmoinen","wrongPassword":false}],"cmd":"load-exam"}
```

* If not all exams are decrypted (due to false or unsufficient number of passwords), exampack is not loaded.

### Start-new-exam
Loads a new exam and starts the exam immediatly.
* Input:`start-new-exam [filename] [keycodefile]`
    - See Load-exam for more info
* Output: JSON `{"error":true/false, "load-exam":{...}, "decrypt": [], "start-exam":{...}, "cmd":"start-new-exam"}`
```json
{"error":false,"load-exam":["exam_koetiedosto1_mex.meb","exam_koetiedosto2.meb"],"decrypt":[{"mebs":["exam_koetiedosto1_mex.meb"],"password":"varmasti munaus sovittaa optio","wrongPassword":false},{"mebs":["exam_koetiedosto1_mex.meb","exam_koetiedosto2.meb"],"password":"konttaus urjeta laskelma ilmoinen","wrongPassword":false}],"start-exam":{"startTime":"2020-11-03T12:16:53.248Z"},"cmd":"start-new-exam"}
```


### Ping
Command for testing if server API is up.
* Input `ping`
* Output `ping`


### Start-loaded-exam
Starts exam already loaded to the server
* Input `start-loaded-exam`
* Output: JSON `{"error":true/false, "start-exam":{...}, "cmd":"start-loaded-exam"}`
```json
{"error":false,"start-exam":{"startTime":"2020-11-03T12:16:53.248Z"},"cmd":"start-new-exam"}
```

### Change-keycode

* Input `change-keycode`
* Output: JSON `{"error":true/false, "change-keycode":{...}, "cmd":"change-keycode"}`
```json
{"error":false, "change-keycode":{"keyCode":"1234","confirmationCode":"xx"}, "cmd":"change-keycode"}
```

### Get-Status
Returns status of the surveillance view on the server containing current keycode and students.
* Input `get-status`
* Output:
    - `output`:
    - `stats`: See stats
```json
{"students":[{"authorized":true,"studentUuid":"e319bf74-ae46-4f26-9589-0345c6c13f19","firstNames":"Testi","lastName":"Oppilas","studentBd":"020202","examTitle":"Exam name","pingError":false,"examStarted":"2020-11-05T19:48:10.343Z","examFinished":null,"updateTime":null,"lastAccessedMedia":null,"nsaRunSuccessCount":0,"nsaRunAdjacentFailCount":0,"studentStatus":"ok","casRestricted":false,"casStatus":"allowed"}],"refreshedCount":"1","hasStarted":true,"startTime":"2020-11-03T12:16:53.248Z","answerPaperCount":"1","backupDiskFreePercentage":100,"rootDiskFreePercentage":97,"replicationStatus":"NEVER_CONNECTED","audioInSomeExam":false,"fileIntegrityCompromised":false,"singleSecurityCode":{"keyCode":"1234","confirmationCode":"xx"}}
```

### Get-Loaded-Exam
Returns currently loaded exam status and their start time
* Input `get-loaded-exam`
* Output:
    - `output`:
    - `exams`: See exams
```json
[{"type":"xml","examUuid":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaaa","examTitle":"Exam name","hasStarted":true,"startTime":"2020-11-03T12:16:53.248Z"},{"type":"json","examUuid":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaab","examTitle":"Another name","hasStarted":true,"startTime":"2020-11-03T12:16:53.248Z"}]d
```

### Get-Opinsys-Info
Returns the version of KTP-API installed to the server
* Input `get-loaded-exam`
* Output: raw version number of KTP-API

### Shutdown-server
Shutdowns the virtual machine server without timeout
* Input `shutdown-server`
* Output: none

### Update
Updates itself by running "kpuapu-asennin" script, if it exists.

## Output files

### exams
Unstarted exams:
```json
[{"type":"xml"/"json","examUuid":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaaa","examTitle":"Exam name","hasStarted":false/true,"startTime":null},{"type":"json","examUuid":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaab","examTitle":"Another name","hasStarted":false,"startTime":null}]
```
Started exams:
```json
[{"type":"xml","examUuid":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaaa","examTitle":"Exam name","hasStarted":true,"startTime":"2020-11-03T12:16:53.248Z"},{"type":"json","examUuid":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaab","examTitle":"Another name","hasStarted":true,"startTime":"2020-11-03T12:16:53.248Z"}]d
```

### stats
Unstarted exam:
```json
{"students":[],"refreshedCount":"0","hasStarted":false,"startTime":null,"answerPaperCount":"0","backupDiskFreePercentage":100,"rootDiskFreePercentage":97,"replicationStatus":"NEVER_CONNECTED","audioInSomeExam":false,"fileIntegrityCompromised":false,"singleSecurityCode":{"keyCode":"1234","confirmationCode":"xx"}}
```
Started exam:
```json
{"students":[{"authorized":true,"studentUuid":"e319bf74-ae46-4f26-9589-0345c6c13f19","firstNames":"Testi","lastName":"Oppilas","studentBd":"020202","examTitle":"Exam name","pingError":false,"examStarted":"2020-11-05T19:48:10.343Z","examFinished":null,"updateTime":null,"lastAccessedMedia":null,"nsaRunSuccessCount":0,"nsaRunAdjacentFailCount":0,"studentStatus":"ok","casRestricted":false,"casStatus":"allowed"}],"refreshedCount":"1","hasStarted":true,"startTime":"2020-11-03T12:16:53.248Z","answerPaperCount":"1","backupDiskFreePercentage":100,"rootDiskFreePercentage":97,"replicationStatus":"NEVER_CONNECTED","audioInSomeExam":false,"fileIntegrityCompromised":false,"singleSecurityCode":{"keyCode":"1234","confirmationCode":"xx"}}
```


## Known issues

- If `.opinsys/cmd` file is deleted, the first command on newly created file does not trigger API handler on virtualized server. The second command will register.
