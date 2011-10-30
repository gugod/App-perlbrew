#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use App::perlbrew;

*ed = *App::perlbrew::editdist;
is ed(qw/Joe Jim/), 2;
is ed(qw/Jack Jill/), 3;
is ed(qw/Jim Jimmy/), 2;
is ed(qw/superman supergirl/), 4;
is ed(qw/supercalifragilisticexpyalligocious superman/), 29;
is ed(qw/foo bar/), 3;

done_testing;
