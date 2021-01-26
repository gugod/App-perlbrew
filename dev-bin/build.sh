#!/bin/bash

SHELL=/bin/bash
eval "$(perlbrew init-in-bash)"
# source $HOME/perl5/perlbrew/etc/bashrc

wanted_perl_installation="perl-5.8.9@perlbrew"

perlbrew use ${wanted_perl_installation}

if [ $? -eq 0 ]; then
   echo "--- Using ${wanted_perl_installation} for building."
else
   echo "!!! Fail to use ${wanted_perl_installation} for building. Please prepare it first."
fi

cpanm File::Path App::FatPacker

cd $(dirname $0)/../
cpanm --installdeps .

cd $(dirname $0)

fatpack_path=$(which fatpack)

if [ ! -f "$fatpack_path" ]; then
    echo "!!! fatpack is missing"
    exit 2
else
    echo "--- Found fatpack at $fatpack_path"
fi

rm -rf fatlib/
mkdir fatlib/

rm -rf lib/App
mkdir -p lib/App

./update-fatlib.pl

cp ../lib/App/perlbrew.pm lib/App/perlbrew.pm
cp -r ../lib/App/Perlbrew lib/App/

export PERL5LIB="lib":$PERL5LIB

cat - <<"EOF" > perlbrew
#!/usr/bin/perl

use strict;
use Config;
BEGIN {
    my @oldinc = @INC;
    @INC = ( $Config{sitelibexp}."/".$Config{archname}, $Config{sitelibexp}, @Config{qw<vendorlibexp vendorarchexp archlibexp privlibexp>} );
    require Cwd;
    @INC = @oldinc;
}

EOF

(fatpack file; cat ../script/perlbrew) >> perlbrew

chmod +x perlbrew
mv ./perlbrew ../

echo "+++ DONE: './perlbrew' is built."
exit 0;
