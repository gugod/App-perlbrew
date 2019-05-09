#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require 'test_helpers.pl';

use Test::More;
use Test::Exception;

## main

note "PERLBREW_ROOT set to $ENV{PERLBREW_ROOT}";
{
    my $app = App::perlbrew->new;
    my @installed = list_locally_installed_perls ($app);
    is 0+@installed, 0;
}

{
    my $app = App::perlbrew->new("install", "perl-5.14.0");
    $app->run;

    my @installed = list_locally_installed_perls ($app);
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
};

subtest "do not clobber exitsing user-specified name." => sub {
    my $app = App::perlbrew->new("install", "perl-5.14.0", "--as", "the-dude");
    $app->run;

    my @installed = list_locally_installed_perls ($app);
    is 0+@installed, 2;

    ok grep { $_->{name} eq 'the-dude' } $app->installed_perls;

    dies_ok {
        my $app = App::perlbrew->new("install", "perl-5.14.0", "--as", "the-dude");
        $app->run;
    } "should die when doing install with existing user-specified name.";
};

done_testing;
