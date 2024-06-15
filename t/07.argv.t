#!/usr/bin/env perl
use Test2::V0;
use App::perlbrew;

{
    my $app = App::perlbrew->new("-Dcc=ccache gcc");
    is $app->{D}[0], 'cc=ccache gcc';
}

{
    my $app = App::perlbrew->new("-Dcc=ccache gcc", "-Dld=gcc");
    is $app->{D}[0], 'cc=ccache gcc';
    is $app->{D}[1], 'ld=gcc';
}

{
    my $app = App::perlbrew->new("install", "-v", "perl-5.14.0", "-Dcc=ccache gcc", "-Dld=gcc");
    is $app->{D}[0], 'cc=ccache gcc';
    is $app->{D}[1], 'ld=gcc';
}

done_testing;
