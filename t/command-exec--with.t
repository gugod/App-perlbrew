#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require 'test_helpers.pl';

use Test::Spec;

mock_perlbrew_install("perl-5.12.3");
mock_perlbrew_install("perl-5.12.4");
mock_perlbrew_install("perl-5.14.1");
mock_perlbrew_install("perl-5.14.2");

describe 'perlbrew exec --with perl-5.12.3 perl -E "say 42"' => sub {
    it "invokes perl-5.12.3/bin/perl" => sub {
        my $app = App::perlbrew->new(qw(exec --with perl-5.12.3 perl -E), "say 42");

        $app->expects("do_system")->returns(
            sub {
                my ($self, @args) = @_;

                my ($perlbrew_bin_path, $perlbrew_perl_bin_path, @paths) = split(":", $ENV{PATH});

                is $perlbrew_bin_path,      file($App::perlbrew::PERLBREW_ROOT, "bin");
                is $perlbrew_perl_bin_path, file($App::perlbrew::PERLBREW_ROOT, "perls", "perl-5.12.3", "bin");

                return 0;
            }
        );

        $app->run;
    };
};

runtests unless caller;
