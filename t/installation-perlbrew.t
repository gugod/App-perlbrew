#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require 'test_helpers.pl';

use Path::Class;
use Test::More;

note "PERLBREW_ROOT set to $ENV{PERLBREW_ROOT}";

subtest "`perlbrew self-install` initialize the required dir structure under PERLBREW_ROOT", sub {
    my $app = App::perlbrew->new('--quiet', 'self-install');
    $app->run;

    ok -d dir($ENV{PERLBREW_ROOT}, "bin");
    ok -d dir($ENV{PERLBREW_ROOT}, "etc");
    ok -d dir($ENV{PERLBREW_ROOT}, "perls");
    ok -d dir($ENV{PERLBREW_ROOT}, "dists");
    ok -d dir($ENV{PERLBREW_ROOT}, "build");

    ok -f file($ENV{PERLBREW_ROOT}, "bin", "perlbrew");
    ok -f file($ENV{PERLBREW_ROOT}, "etc", "bashrc");
    ok -f file($ENV{PERLBREW_ROOT}, "etc", "cshrc");
};

done_testing;
