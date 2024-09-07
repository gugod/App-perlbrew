#!perl
use Test2::V0;

use App::perlbrew;
use File::Temp qw( tempdir );
$App::perlbrew::PERLBREW_ROOT = tempdir( CLEANUP => 1 );
$App::perlbrew::PERLBREW_HOME = tempdir( CLEANUP => 1 );
$ENV{PERLBREW_ROOT} = $App::perlbrew::PERLBREW_ROOT;

my $app = App::perlbrew->new();
$app->cpan_mirror("https://www.cpan.org");

my $rd = { type => "perl", "version" => "5.18.2" };
my ($error, undef) = $app->release_detail_perl_local("perl-5.18.2", $rd);

ok !$error, 'no error';
ok defined( $rd->{tarball_url} ), 'tarball_url is defined';
ok defined( $rd->{tarball_url} ), 'tarball_url is defined';

is $rd->{tarball_url}, "https://www.cpan.org/authors/id/R/RJ/RJBS/perl-5.18.2.tar.bz2",
    'tarball_url is correct';
is $rd->{tarball_name}, "perl-5.18.2.tar.bz2",
    'tarball_name is correct';

done_testing;
