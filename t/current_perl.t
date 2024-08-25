#!/usr/bin/env perl
use Test2::V0;
use Test2::Tools::Spec;
use App::perlbrew;

use FindBin;
use lib $FindBin::Bin;
require 'test2_helpers.pl';

mock_perlbrew_install("perl-5.12.3");
mock_perlbrew_install("perl-5.12.4");
mock_perlbrew_install("perl-5.14.1");
mock_perlbrew_install("perl-5.14.2");

describe "current perl" => sub {
    it "is decided from env var PERLBREW_PERL" => sub {
        for my $v (qw(perl-5.12.3 perl-5.12.3 perl-5.14.1 perl-5.14.2)) {
            local $ENV{PERLBREW_PERL} = $v;
            my $app = App::perlbrew->new;
            is $app->current_perl, $v;
        }
    };

    it "can be decided from object attribute, which overrides env var." => sub {
        local $ENV{PERLBREW_PERL} = "perl-5.12.3";

        for my $v (qw(perl-5.12.3 perl-5.12.3 perl-5.14.1 perl-5.14.2)) {
            my $app = App::perlbrew->new;
            $app->{current_perl} = $v;
            is $app->current_perl, $v;
        }
    };

    it "can be set with current_perl method." => sub {
        local $ENV{PERLBREW_PERL} = "perl-5.12.3";

        for my $v (qw(perl-5.12.3 perl-5.12.3 perl-5.14.1 perl-5.14.2)) {
            my $app = App::perlbrew->new;
            is $app->current_perl, "perl-5.12.3";

            $app->current_perl($v);
            is $app->current_perl, $v;
        }
    };
};

done_testing;
