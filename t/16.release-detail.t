#!perl
use strict;
use App::perlbrew;
use File::Temp qw( tempdir );
$App::perlbrew::PERLBREW_ROOT = tempdir( CLEANUP => 1 );
$App::perlbrew::PERLBREW_HOME = tempdir( CLEANUP => 1 );
$ENV{PERLBREW_ROOT} = $App::perlbrew::PERLBREW_ROOT;

use Test::More;

subtest 'parse "perl-5.18.2"' => sub {
    my $app = App::perlbrew->new();

    my $rd = $app->release_detail("perl-5.18.2");

    ok defined( $rd->{type} );
    ok defined( $rd->{version} );
    ok defined( $rd->{tarball_url} );
    ok defined( $rd->{tarball_name} );

    is $rd->{type}, "perl";
    is $rd->{version}, "5.18.2";
};

subtest 'parse "5.18.2"' => sub {
    my $app = App::perlbrew->new();

    my $rd = $app->release_detail("5.18.2");

    ok defined( $rd->{type} );
    ok defined( $rd->{version} );
    ok defined( $rd->{tarball_url} );
    ok defined( $rd->{tarball_name} );

    is $rd->{type}, "perl";
    is $rd->{version}, "5.18.2";
};

subtest 'parse "cperl-5.22.2"' => sub {
    my $app = App::perlbrew->new();

    my $rd = $app->release_detail("cperl-5.22.2");

    ok defined( $rd->{type} );
    ok defined( $rd->{version} );
    ok defined( $rd->{tarball_url} );
    ok defined( $rd->{tarball_name} );

    is $rd->{type}, "cperl";
    is $rd->{version}, "5.22.2";
};

done_testing;
