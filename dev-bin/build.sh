#!/bin/sh

export PERL5LIB=lib:$PERL5LIB
(echo "#!/usr/bin/env perl"; fatpack file; cat bin/perlbrew) > perlbrew
chmod +x perlbrew
