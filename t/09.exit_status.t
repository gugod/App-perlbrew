#!/usr/bin/env perl
use Test2::V0;

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require 'test2_helpers.pl';

use Path::Class;

my $bin_perlbrew = file(__FILE__)->dirname->dirname->child("script")->child("perlbrew");

like(
    dies {
        my $app = App::perlbrew->new("unknown-command");
        $app->run;
    },
    qr[unknown-command],
    'unknown-command error'
);

my $perl = $^X;
system("$perl -Ilib ${bin_perlbrew} unknown-command 2>&1");
isnt $?, 0, 'unknown-command command error';

system("$perl -Ilib ${bin_perlbrew} version 2>&1");
is $?, 0, 'version command';

done_testing;

