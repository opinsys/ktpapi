# API Description

KTP-API is based on commands written on filesystem level into `.opinsys/cmd` file in `ktp-jako/` folder on ktp

Following commands are supported

* `load-exam [filename] [keycodefile]`
* `start-new-exam [filename] [keycodefile]`
* `start-loaded-exam`
* `change-keycode`
* `get-status`
* `get-keycode`
* `get-loaded-exam`
* `get-opinsys-info`
* `get-server-version`
* `ping`
* `store-exam-results [filename]`
* `shutdown-server`

Commandfile `.opinsys-cmd` may only contain single command. Result is stored in following files.
* `.opinsys/cmd-stamp`
* `.opinsys/cmd-result`
* `.opinsys/stats`
* `.opinsys/exams`