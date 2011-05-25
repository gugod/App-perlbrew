#!/usr/bin/env perl
use strict;
use warnings;
use Path::Class;
use IO::All;
BEGIN {
    $ENV{PERLBREW_ROOT} = file(__FILE__)->dir->subdir("mock_perlbrew_root");
}

use Test::More;
use App::perlbrew;
use Try::Tiny;

## setup

App::perlbrew::rmpath( $ENV{PERLBREW_ROOT} );

## mock

no warnings 'redefine';

sub App::perlbrew::do_install_release {
    my ($self, $name) = @_;

    my $root = dir($ENV{PERLBREW_ROOT});
    my $installation_dir = $root->subdir("perls", $name);
    App::perlbrew::mkpath($installation_dir);
    App::perlbrew::mkpath($root->subdir("perls", $name, "bin"));

    my $perl = $root->subdir("perls", $name, "bin")->file("perl");
    io($perl)->print("#!/bin/sh\nperl \"\$@\";\n");
    chmod 0755, $perl;
}

use warnings;

## main

note "PERLBREW_ROOT set to $ENV{PERLBREW_ROOT}";
{
    my $app = App::perlbrew->new;
    my @installed = grep { !$_->{is_external} } $app->installed_perls;
    is 0+@installed, 0;
}

{
    my $app = App::perlbrew->new("install", "perl-5.14.0");
    $app->run;

    my @installed = grep { !$_->{is_external} } $app->installed_perls;
    is 0+@installed, 1;

    is $installed[0]->{name}, "perl-5.14.0";
}

done_testing;
