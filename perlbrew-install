#!/bin/sh


clean_exit () {
    [ -f $LOCALINSTALLER ] && rm $LOCALINSTALLER
    exit $1
}

LOCALINSTALLER=$(mktemp perlbrew.XXXXXX)

if [ -z "${PERLBREWURL}" ]; then
    PERLBREWURL=https://raw.githubusercontent.com/gugod/App-perlbrew/master/perlbrew
fi

if [ -z "$TMPDIR" ]; then
    if [ -d "/tmp" ]; then
        TMPDIR="/tmp"
        cd $TMPDIR || clean_exit 1
    else
        TMPDIR="."
    fi
fi





echo
if type curl >/dev/null 2>&1; then
  PERLBREWDOWNLOAD="curl -f -sS -Lo $LOCALINSTALLER $PERLBREWURL"
elif type fetch >/dev/null 2>&1; then
  PERLBREWDOWNLOAD="fetch -o $LOCALINSTALLER $PERLBREWURL"
elif type wget >/dev/null 2>&1; then
  PERLBREWDOWNLOAD="wget -nv -O $LOCALINSTALLER $PERLBREWURL"
else
  echo "Need either wget, fetch or curl to use $0"
  clean_exit
fi


echo "## Download the latest perlbrew"
$PERLBREWDOWNLOAD || clean_exit 1

echo
echo "## Installing perlbrew"

# loop thru available well known Perl installations
for PERL in "/usr/bin/perl" "/usr/local/bin/perl"
do
    [ -x "$PERL" ] && echo "Using Perl <$PERL>" && break
done

if [ ! -x "$PERL" ]; then
  echo "Need /usr/bin/perl or /usr/local/bin/perl to use $0"
  clean_exit 2
fi

[ ! -x $LOCALINSTALLER ] && chmod +x $LOCALINSTALLER
$PERL $LOCALINSTALLER self-install || clean_exit 3

echo "## Installing patchperl"
$PERL $LOCALINSTALLER -f -q install-patchperl || clean_exit 4

echo
echo "## Done."
rm ./$LOCALINSTALLER
