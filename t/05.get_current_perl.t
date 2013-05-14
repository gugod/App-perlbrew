#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require 'test_helpers.pl';

use Test::More;
use Test::Output;

mock_perlbrew_install("perl-5.12.3");
mock_perlbrew_install("perl-5.12.4");
mock_perlbrew_install("perl-5.14.1");
mock_perlbrew_install("perl-5.14.2");

subtest "perlbrew version" => sub {

    my $version = $App::perlbrew::VERSION;
    stdout_like(
        sub {
            my $app = App::perlbrew->new("version");
            $app->run;
        } =>
        qr{(?:\./)?\Qt/05.get_current_perl.t  - App::perlbrew/$version\E\n}
    );
};

subtest "Current perl is decided from environment variable PERLBREW_PERL" => sub {
    for my $v (qw(perl-5.12.3 perl-5.12.3 perl-5.14.1 perl-5.14.2)) {
        local $ENV{PERLBREW_PERL} = $v;
        my $app = App::perlbrew->new;
        is $app->current_perl, $v;
    }
};


subtest "Current perl can be decided from object attribute, which overrides env var." => sub {
    local $ENV{PERLBREW_PERL} = "perl-5.12.3";

    for my $v (qw(perl-5.12.3 perl-5.12.3 perl-5.14.1 perl-5.14.2)) {
        my $app = App::perlbrew->new;
        $app->{current_perl} = $v;
        is $app->current_perl, $v;
    }
};

done_testing;
