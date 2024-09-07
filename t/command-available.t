#!/usr/bin/env perl
use Test2::V0;
use Test2::Tools::Spec;
use File::Temp qw( tempdir );

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require "test2_helpers.pl";

use PerlbrewTestHelpers qw(stdout_like);

$App::perlbrew::PERLBREW_ROOT = my $perlbrew_root = tempdir( CLEANUP => 1 );
$App::perlbrew::PERLBREW_HOME = my $perlbrew_home = tempdir( CLEANUP => 1 );

my %available_perl_dists = (
    'perl-5.27.4'  => 'http://www.cpan.org/src/5.0/perl-5.27.4.tar.gz',
    'perl-5.26.1'  => 'http://www.cpan.org/src/5.0/perl-5.26.1.tar.gz',
    'perl-5.24.3'  => 'http://www.cpan.org/src/5.0/perl-5.24.3.tar.gz',
    'perl-5.22.4'  => 'http://www.cpan.org/src/5.0/perl-5.22.4.tar.gz',
    'perl-5.20.3'  => 'http://www.cpan.org/src/5.0/perl-5.20.3.tar.gz',
    'perl-5.18.4'  => 'http://www.cpan.org/src/5.0/perl-5.18.4.tar.gz',
    'perl-5.16.3'  => 'http://www.cpan.org/src/5.0/perl-5.16.3.tar.gz',
    'perl-5.14.4'  => 'http://www.cpan.org/src/5.0/perl-5.14.4.tar.gz',
    'perl-5.12.5'  => 'http://www.cpan.org/src/5.0/perl-5.12.5.tar.gz',
    'perl-5.10.1'  => 'http://www.cpan.org/src/5.0/perl-5.10.1.tar.gz',
    'perl-5.8.9'   => 'http://www.cpan.org/src/5.0/perl-5.8.9.tar.gz',
    'perl-5.6.2'   => 'http://www.cpan.org/src/5.0/perl-5.6.2.tar.gz',
    'perl5.005_04' => 'http://www.cpan.org/src/5.0/perl5.005_04.tar.gz',
    'perl5.004_05' => 'http://www.cpan.org/src/5.0/perl5.004_05.tar.gz',
);

sub mocked_perlbrew {
    my $app = App::perlbrew->new( @_ );

    my $mock = mock $app,
        override => [
            available_perl_distributions => sub { \%available_perl_dists }
        ];

    return ($mock, $app);
}

describe "available command output, when nothing installed locally," => sub {
    it "should display a list of perl versions" => sub {
        my ($mock, $app) = mocked_perlbrew( "available", "--verbose" );

        stdout_like sub {
            $app->run();
        }, qr{
              \A
              (
                  \# .+ \n
                  (
                      \s{3,}c?perl-?\d\.\d{1,3}[_.]\d{1,2}
                      \s+
                      available \s from
                      \s+
                      <https?:\/\/.+>
                      \s*?
                      \n
                  )+
                  \n
              )+
              \z
        }sx;
    };
};

describe "available command output, when something installed locally," => sub {
    it "should display a list of perl versions, with markers on installed versions" => sub {
        my ($mock, $app) = mocked_perlbrew( "available", "--verbose" );

        my @installed_perls = (
            { name => "perl-5.24.0" },
            { name => "perl-5.20.3" }
        );

        $mock->override(
            "installed_perls" => sub  { @installed_perls }
        );

        stdout_like sub {
            $app->run();
        }, qr{
              \A
              (
                  \# .+ \n
                  (
                      \s{3,}perl-?\d\.\d{1,3}[_.]\d{1,2}
                      \s+
                      (
                          INSTALLED \s on \s .+ \s via
                          | available \s from
                      )
                      \s+
                      <https?:\/\/.+>
                      \s*?
                      \n
                  )+
                  \n
              )+
              \z
        }sx;
    };
};

done_testing;
