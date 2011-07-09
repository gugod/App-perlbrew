#!/usr/bin/env perl
use strict;
use warnings;
use Path::Class;
use IO::All;
BEGIN {
    $ENV{PERLBREW_ROOT} = file(__FILE__)->dir->subdir("mock_perlbrew_root");
}

use App::perlbrew;
use Test::Spec;
use Test::Exception;

App::perlbrew::rmpath( $ENV{PERLBREW_ROOT} );
## mock

no warnings 'redefine';

sub App::perlbrew::do_install_release {
    my ($self, $name) = @_;

    $name = $self->{as} if $self->{as};

    my $root = dir($ENV{PERLBREW_ROOT});
    my $installation_dir = $root->subdir("perls", $name);
    App::perlbrew::mkpath($installation_dir);
    App::perlbrew::mkpath($root->subdir("perls", $name, "bin"));

    my $perl = $root->subdir("perls", $name, "bin")->file("perl");
    io($perl)->print("#!/bin/sh\nperl \"\$@\";\n");
    chmod 0755, $perl;
}

use warnings;

App::perlbrew->new("install", "perl-5.8.9")->run();
App::perlbrew->new("install", "perl-5.14.0")->run();
App::perlbrew->new("install", "--as" => "5.8.9", "perl-5.8.9")->run();
App::perlbrew->new("install", "--as" => "perl-shiny", "perl-5.14.0")->run();

## spec

describe "App::perlbrew->resolve_installation_name" => sub {
    my $app;

    before each => sub {
        $app = App::perlbrew->new;
    };

    it "takes exactly one argument, which means the `shortname` that needs to be resolved to a `longname`", sub {
        ok $app->resolve_installation_name("5.8.9");
        dies_ok {
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
};

runtests unless caller;
