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

use App::perlbrew;

throws_ok(
    sub {
        my $app = App::perlbrew->new("unknown-command");
        $app->run;
    },
    qr[unknown_command]
);

`perlbrew unknown-command 2>&1`;
ok($? != 0);

`perlbrew version 2>&1`;
ok($? == 0);

done_testing;

