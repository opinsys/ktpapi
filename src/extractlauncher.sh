echo "Puretaan asennuspakettia"

export TMPDIR=`mktemp -d /tmp/purku.XXXXXX`

ARCHIVE=`awk '/^___ARCHIVE_BELOW___/ {print NR + 1; exit 0; }' $0`

tail -n+$ARCHIVE $0 | tar xzv -C $TMPDIR

CDIR=`pwd`
cd $TMPDIR
./installer

cd $CDIR
rm -rf $TMPDIR

exit 0