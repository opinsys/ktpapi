#!/bin/sh

set -eu

# This patch makes it possible to upload a zip file without any exams
# (with "load-exam"),  and this will remove the currents exams.

if [ ! -e /var/lib/ktpjs/server/routes/import-exam-bl.js.orig ]; then
  sudo -n patch -b -d / -N -p1 <<'EOF'
--- /var/lib/ktpjs/server/routes/import-exam-bl.js	2021-02-09 13:58:40.000000000 +0000
+++ /var/lib/ktpjs/server/routes/import-exam-bl.js	2021-02-18 08:38:19.159000000 +0000
@@ -520,6 +520,7 @@
 
   const mebFileList = await listFilesFromZip(absolutePackagePath, examPackageExtensions)
   if (mebFileList.length === 0) {
+    using(pgrm.getTransaction(), async tx => { clearDatabase(tx).tap(clearFiles) })
     return [uploadedExamPackage]
   } else {
     const mebs = await extractMultiExamPackage(absolutePackagePath, examTempPath)
EOF
fi
