#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require 'test_helpers.pl';

use Test::More;
use Test::Exception;
use Path::Class;

my $bin_perlbrew = file(__FILE__)->dir->parent->subdir("bin")->file("perlbrew");

throws_ok(
    sub {
        my $app = App::perlbrew->new("unknown-command");
        $app->run;
    },
    qr[unknown-command]
);

system("perl -Ilib ${bin_perlbrew} unknown-command 2>&1");
ok($? != 0);

system("perl -Ilib ${bin_perlbrew} version 2>&1");
ok($? == 0);

done_testing;

