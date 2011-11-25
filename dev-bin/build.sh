#!/bin/sh

export PERL5LIB=lib:$PERL5LIB
# fatpack trace bin/perlbrew
# fatpack packlists-for `cat fatpacker.trace` > packlists
# fatpack tree `cat packlists`
(echo "#!/usr/bin/env perl"; fatpack file; cat bin/perlbrew) > perlbrew
chmod +x perlbrew
