#!/usr/bin/env perl
use strict;
use warnings;
use Path::Class;
use IO::All;
BEGIN {
    $ENV{PERLBREW_ROOT} = file(__FILE__)->dir->subdir("mock_perlbrew_root");
}

use Test::More;
use Test::Exception;
use App::perlbrew;

## setup

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

    dies_ok {
        my $app = App::perlbrew->new("install", "perl-5.14.0");
        $app->run;
    } "should die when doing install with existing distribution name.";
}

subtest "App::perlbrew#is_installed method." => sub {
    my $app = App::perlbrew->new;
    ok $app->can("is_installed");
    ok $app->is_installed("perl-5.14.0");
    ok !$app->is_installed("perl-5.13.0");

    done_testing;
};

subtest "do not clobber exitsing user-specified name." => sub {
    my $app = App::perlbrew->new("install", "perl-5.14.0", "--as", "the-dude");
    $app->run;

    my @installed = grep { !$_->{is_external} } $app->installed_perls;
    is 0+@installed, 2;

    ok grep { $_->{name} eq 'the-dude' } $app->installed_perls;

    dies_ok {
        my $app = App::perlbrew->new("install", "perl-5.14.0", "--as", "the-dude");
        $app->run;
    } "should die when doing install with existing user-specified name.";

    done_testing;
};

done_testing;
