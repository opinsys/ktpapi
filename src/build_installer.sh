#!/bin/bash
cd "$(dirname "$0")"

target_platform=$1||"SERVER2041X"
target_dir=../dist
target_file="$target_dir"/installer.sh

case $target_platform in 
    "SERVER2003K")
        target_platform_dir=./platform/$target_platform
        target_platform_deb_dir=./platform/$target_platform
        target_file="$target_dir"/installer-${target_platform,,}
        ;;
    "SERVER2041X")
        target_platform_dir=./platform/$target_platform
        target_platform_deb_dir=./platform/$target_platform
        target_file="$target_dir"/installer-${target_platform,,}
        ;;
    *)
        echo "Build script does not support platform $target_platform!"
        exit 1
        ;;
    esac

tempdir=`mktemp -d ktpapiinstaller.XXX` 

# Gather delivarable files
cp installscript.sh $tempdir/installer.sh
cp apiwatcher.sh $tempdir/apiwatcher.sh
cp "$target_platform_deb_dir"/curl*.deb $tempdir/curl.deb
cp "$target_platform_deb_dir"/libcurl*.deb $tempdir/libcurl.deb
cp -r ./systemd $tempdir
cp "$target_platform_dir"/opinsys-download-progress $tempdir/opinsys-download-progress
cp "$target_platform_dir"/opinsys-download-progress-installer.sh $tempdir/opinsys-download-progress-installer.sh

# Pack target
mkdir -p $target_dir
cat "extractlauncher.sh" > $target_file
echo '___ARCHIVE_BELOW___' >> $target_file
tar -czv -C $tempdir . >> $target_file
chmod a+x $target_file

# Cleanup
rm -rf $tempdir