#!/usr/bin/env perl
use Test2::V0;
use Test2::Tools::Spec;

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require "test2_helpers.pl";

mock_perlbrew_install("perl-5.8.9");
mock_perlbrew_install("perl-5.14.0");
mock_perlbrew_install("perl-5.8.9",  "--as" => "5.8.9");
mock_perlbrew_install("perl-5.14.0", "--as" => "perl-shiny", "perl-5.14.0");

{
    no warnings 'redefine';
    sub App::perlbrew::current_perl { "perl-5.14.0" }
}

## spec

describe "App::perlbrew->resolve_installation_name" => sub {
    my $app;

    before_each new_perlbrew => sub {
        $app = App::perlbrew->new;
    };

    it "takes exactly one argument, which means the `shortname` that needs to be resolved to a `longname`", sub {
        ok $app->resolve_installation_name("5.8.9");
        ok dies {
            $app->resolve_installation_name; # no args
        };
    };

    it "returns the same value as the argument if there is an installation with exactly the same name", sub {
        is $app->resolve_installation_name("5.8.9"), "5.8.9";
        is $app->resolve_installation_name("perl-5.8.9"), "perl-5.8.9";
        is $app->resolve_installation_name("perl-5.14.0"), "perl-5.14.0";
    };

    it "returns `perl-\$shortname` if that happens to be a proper installation name.", sub {
        is $app->resolve_installation_name("5.14.0"), "perl-5.14.0";
        is $app->resolve_installation_name("shiny"), "perl-shiny";
    };

    it "returns undef if no proper installation can be found", sub {
        is $app->resolve_installation_name("nihao"), undef;
    };

    describe 'with lib names' => sub {
        it 'returns both perl version and libnames' => sub {
            my ($v, $l) = $app->resolve_installation_name('perl-5.14.0@soya');
            is $v, "perl-5.14.0";
            is $l, "soya";
        };

        it 'returns current perl version when only a libname is given' => sub {
            my ($v, $l) = $app->resolve_installation_name('@soya');
            is $v, $app->current_perl;
            is $l, "soya";
        };
    };
};

done_testing;