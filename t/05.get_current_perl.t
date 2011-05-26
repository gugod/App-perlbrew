#!/usr/bin/env perl
use strict;
use warnings;
use lib qw(lib);
use Test::More tests => 1;
use App::perlbrew;
use Test::Output;

my $app = App::perlbrew->new();
my $version = $App::perlbrew::VERSION;

stdout_is(
    sub {
        $app->run_command('version');
    },
    "t/05.get_current_perl.t  - App::perlbrew/$version\n",
    'Test version'
);
