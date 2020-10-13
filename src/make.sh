#!/bin/bash

target_dir=../dist
target_file=$target_dir/installer.sh

target_platform_dir=./platforms/SERVER2040X
tempdir=`mktemp -d ktpapiinstaller.XXX` 

# Gather delivarable files
cp installscript.sh $tempdir/installer.sh
cp apiwatcher.sh $tempdir/apiwatcher.sh
cp $target_platform_dir/curl*.deb $tempdir/curl.deb
cp $target_platform_dir/libcurl*.deb $tempdir/libcurl.deb

# Pack target
cat extractlauncher.sh > $target_file
echo '___ARCHIVE_BELOW___' >> $target_file
tar -czv $tempdir >> $target_file

# Cleanup
rm -rf $tempdir