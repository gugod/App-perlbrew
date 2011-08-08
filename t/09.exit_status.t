#!/usr/bin/env perl
use strict;
use warnings;
use lib qw(lib);
use Test::More;
use Test::Exception;
use Path::Class;

BEGIN {
    $ENV{PERLBREW_ROOT} = file(__FILE__)->dir->subdir("mock_perlbrew_root");
}

my $bin_perlbrew = file(__FILE__)->dir->parent->subdir("bin")->file("perlbrew");

use App::perlbrew;

throws_ok(
    sub {
        my $app = App::perlbrew->new("unknown-command");
        $app->run;
    },
    qr[unknown_command]
);

system("perl -Ilib ${bin_perlbrew} unknown-command 2>&1");
ok($? != 0);

system("perl -Ilib ${bin_perlbrew} version 2>&1");
ok($? == 0);

done_testing;

