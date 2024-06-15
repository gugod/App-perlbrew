#!/usr/bin/env perl
use Test2::V0;

BEGIN {
    delete $ENV{PERLBREW_LIB};
}

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require 'test2_helpers.pl';

{
    no warnings 'redefine';

    sub App::perlbrew::available_perls {
        return map { "perl-$_" }
            qw<5.8.9 5.17.7 5.16.2 5.14.3 5.12.5 5.10.1>;
    }

    sub App::perlbrew::switch_to {
        shift->current_perl(shift);
    }
}

plan 3;

{
    my $app = App::perlbrew->new("install", "--switch", "perl-stable");
    $app->run;

    my @installed = $app->installed_perls;
    is 0+@installed, 1, "install perl-stable installs one perl";

    is $installed[0]{name}, "perl-5.16.2",
        "install perl-stable installs correct perl";

    ok $installed[0]{is_current},
        "install --switch automatically switches to the installed perl"
            or diag explain $installed[0];
}

done_testing;
