#!perl
use strict;
use App::perlbrew;
use File::Temp qw( tempdir );
$App::perlbrew::PERLBREW_ROOT = tempdir( CLEANUP => 1 );
$App::perlbrew::PERLBREW_HOME = tempdir( CLEANUP => 1 );
$ENV{PERLBREW_ROOT} = $App::perlbrew::PERLBREW_ROOT;

use Test::More;

unless ($ENV{TEST_LIVE}) {
    plan skip_all => 'These tests send HTTP requests. Set env TEST_LIVE=1 to really run them.';
}

my $app = App::perlbrew->new();
$app->cpan_mirror("https://www.cpan.org");

my $rd = { type => "perl", "version" => "5.18.2" };
my ($error, undef) = $app->release_detail_perl_remote("perl-5.18.2", $rd);

ok !$error;
ok defined( $rd->{tarball_url} );
ok defined( $rd->{tarball_name} );

is $rd->{tarball_url}, "https://www.cpan.org/src/5.0/perl-5.18.2.tar.bz2";
is $rd->{tarball_name}, "perl-5.18.2.tar.bz2";

done_testing;
