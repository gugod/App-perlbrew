#!/usr/bin/env perl
use Test2::V0;
use Test2::Plugin::IOEvents;

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require 'test2_helpers.pl';

mock_perlbrew_install("perl-5.12.3");
mock_perlbrew_install("perl-5.12.4");
mock_perlbrew_install("perl-5.14.1");
mock_perlbrew_install("perl-5.14.2");

subtest "perlbrew version" => sub {

    my $version = $App::perlbrew::VERSION;
    my $events = intercept {
        my $app = App::perlbrew->new("version");
        $app->run;
    };
    like(
        $events,
        [
            {info => [{tag => 'STDOUT', details => qr{(?:\./)?\Qt/05.get_current_perl.t  - App::perlbrew/$version\E\n}}]}
        ],
        'perlbrew version matches'
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
