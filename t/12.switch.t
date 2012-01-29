#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require 'test_helpers.pl';

mock_perlbrew_install("perl-5.12.3");
mock_perlbrew_install("perl-5.12.4");
mock_perlbrew_install("perl-5.14.1");
mock_perlbrew_install("perl-5.14.2");

delete $ENV{PERLBREW_PERL};
my $current = file($App::perlbrew::PERLBREW_HOME, "version");
ok !-f $current;
my $app = App::perlbrew->new;
is $app->current_perl, "";

{
    my $app = App::perlbrew->new(switch => "perl-5.14.2");
    $app->run;
    is $app->current_perl, "perl-5.14.2";

    $app = App::perlbrew->new;
    is $app->current_perl, "perl-5.14.2";
}

{
    my $app = App::perlbrew->new(switch => "perl-5.14.1");
    $app->run;
    is $app->current_perl, "perl-5.14.1";

    $app = App::perlbrew->new;
    is $app->current_perl, "perl-5.14.1";
}

done_testing;
