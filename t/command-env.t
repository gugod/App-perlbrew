#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { $ENV{SHELL} = "/bin/bash" }

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require "test_helpers.pl";

use File::Temp qw( tempdir );
use File::Spec::Functions qw( catdir );
use File::Path::Tiny;
use Test::Spec;
use Test::Output;

mock_perlbrew_install("perl-5.14.1");

describe "env command," => sub {
    describe "when invoked with a perl installation name", sub {
        it "displays environment variables that should be set to use the given perl." => sub {
            my $app = App::perlbrew->new("env", "perl-5.14.1");

            stdout_is {
                $app->run;
            } <<"OUT";
export PERLBREW_PERL=perl-5.14.1
export PERLBREW_VERSION=$App::perlbrew::VERSION
export PERLBREW_PATH=$App::perlbrew::PERLBREW_ROOT/bin:$App::perlbrew::PERLBREW_ROOT/perls/perl-5.14.1/bin
export PERLBREW_ROOT=$App::perlbrew::PERLBREW_ROOT
OUT
        };
    };
};

runtests unless caller;

