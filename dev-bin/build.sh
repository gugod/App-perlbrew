#!/bin/sh

cd `dirname $0`

perl_version=`perl -e 'print $]'`

if [ $perl_version != "5.008008" ]; then
    echo "!!! Must use 5.8.8 to build standalone executable."
    exit 1;
fi

fatpack_path=`which fatpack`

if [ ! -f $fatpack_path ]; then
    echo "!!! fatpack is missing"
    exit 2
fi

mkdir -p lib/App

if type perlstrip >/dev/null 2>&1; then
    perlstrip -o lib/App/perlbrew.pm ../lib/App/perlbrew.pm
else
    echo "--- perlstrip is not installed. The fatpacked executable will be really big."
fi

export PERL5LIB="lib":$PERL5LIB

cat - <<"EOF" > perlbrew
#!/usr/bin/perl
EOF

(fatpack file; cat ../bin/perlbrew) >> perlbrew

chmod +x perlbrew
mv ./perlbrew ../

echo "+++ DONE"
exit 0;
