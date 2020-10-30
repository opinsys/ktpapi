#!/bin/bash

set -eu

cd "$(dirname "$0")"

target_dir=../dist
target_file="$target_dir"/installer

tempdir=`mktemp -d ktpapiinstaller.XXX`

# Gather delivarable files
cp installscript.sh $tempdir/installer.sh
cp apiwatcher.sh $tempdir/apiwatcher.sh
cp timertrigger.sh $tempdir/timertrigger.sh
cp platforms/ -TR $tempdir
cp -r ./systemd $tempdir

# Pack target
mkdir -p $target_dir
cat "extractlauncher.sh" > $target_file
echo '___ARCHIVE_BELOW___' >> $target_file
tar -czv -C $tempdir . >> $target_file
chmod a+x $target_file

# Cleanup
rm -rf $tempdir
