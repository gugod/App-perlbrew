#!/bin/sh

cd `dirname $0`

mkdir -p lib/App
perlstrip -o lib/App/perlbrew.pm ../lib/App/perlbrew.pm

export PERL5LIB="lib":$PERL5LIB
(echo "#!/usr/bin/env perl"; fatpack file; cat ../bin/perlbrew) > perlbrew
chmod +x perlbrew
mv ./perlbrew ../
