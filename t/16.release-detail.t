#!perl
use Test2::V0;
use Test2::Tools::Subtest qw/subtest_buffered/;
use App::perlbrew;
use File::Temp qw( tempdir );
$App::perlbrew::PERLBREW_ROOT = tempdir( CLEANUP => 1 );
$App::perlbrew::PERLBREW_HOME = tempdir( CLEANUP => 1 );
$ENV{PERLBREW_ROOT} = $App::perlbrew::PERLBREW_ROOT;

subtest_buffered 'parse "perl-5.18.2"' => sub {
    my $app = App::perlbrew->new();

    my $rd = $app->release_detail("perl-5.18.2");

    ok defined( $rd->{type} );
    ok defined( $rd->{version} );
    ok defined( $rd->{tarball_url} );
    ok defined( $rd->{tarball_name} );

    is $rd->{type}, "perl";
    is $rd->{version}, "5.18.2";
};

subtest_buffered 'parse "5.18.2"' => sub {
    my $app = App::perlbrew->new();

    my $rd = $app->release_detail("5.18.2");

    ok defined( $rd->{type} );
    ok defined( $rd->{version} );
    ok defined( $rd->{tarball_url} );
    ok defined( $rd->{tarball_name} );

    is $rd->{type}, "perl";
    is $rd->{version}, "5.18.2";
};

done_testing;
