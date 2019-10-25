#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use App::Perlbrew::Util qw< editdist >;

is editdist(qw/Joe Jim/), 2;
is editdist(qw/Jack Jill/), 3;
is editdist(qw/Jim Jimmy/), 2;
is editdist(qw/superman supergirl/), 4;
is editdist(qw/supercalifragilisticexpyalligocious superman/), 29;
is editdist(qw/foo bar/), 3;

done_testing;
