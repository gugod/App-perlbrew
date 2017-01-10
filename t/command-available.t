#!/usr/bin/env perl
use strict;
use warnings;
use Test::Spec;
use Path::Class;
use IO::All;
use File::Temp qw( tempdir );
use Test::Output;

use App::perlbrew;
$App::perlbrew::PERLBREW_ROOT = my $perlbrew_root = tempdir( CLEANUP => 1 );
$App::perlbrew::PERLBREW_HOME = my $perlbrew_home = tempdir( CLEANUP => 1 );

#
# This is an example of availables perls on fluca1978 machine 2017-01-10.
#
my %available_perls = (
    'perl5.005_04'      => 'http://www.cpan.org/src/5.0/perl5.005_04.tar.gz',
    'perl5.004_05'      => 'http://www.cpan.org/src/5.0/perl5.004_05.tar.gz',
    'perl-5.8.9'        => 'http://www.cpan.org/src/5.0/perl-5.8.9.tar.gz',
    'perl-5.6.2'        => 'http://www.cpan.org/src/5.0/perl-5.6.2.tar.gz',
    'perl-5.24.0'       => 'http://www.cpan.org/src/5.0/perl-5.24.0.tar.gz',
    'perl-5.22.2'       => 'http://www.cpan.org/src/5.0/perl-5.22.2.tar.gz',
    'perl-5.20.3'       => 'http://www.cpan.org/src/5.0/perl-5.20.3.tar.gz',
    'perl-5.18.4'       => 'http://www.cpan.org/src/5.0/perl-5.18.4.tar.gz',
    'perl-5.16.3'       => 'http://www.cpan.org/src/5.0/perl-5.16.3.tar.gz',
    'perl-5.14.4'       => 'http://www.cpan.org/src/5.0/perl-5.14.4.tar.gz',
    'perl-5.12.5'       => 'http://www.cpan.org/src/5.0/perl-5.12.5.tar.gz',
    'perl-5.10.1'       => 'http://www.cpan.org/src/5.0/perl-5.10.1.tar.gz',
    'cperl-5.25.2'      => 'https://github.com//perl11/cperl/releases/download/cperl-5.25.2',
    'cperl-5.25.1'      => 'https://github.com//perl11/cperl/releases/download/cperl-5.25.1',
    'cperl-5.24.2'      => 'https://github.com//perl11/cperl/releases/download/cperl-5.24.2',
    'cperl-5.24.1'      => 'https://github.com//perl11/cperl/releases/download/cperl-5.24.1',
    );


describe "available command output, when nothing installed locally," => sub {
    it "should display a list of perl versions" => sub {
        my $app = App::perlbrew->new("available");


        $app->expects( 'available_perls_with_urls' )->returns( \%available_perls );

        stdout_is sub { $app->run(); }, <<OUT

  perl5.005_04      URL: <http://www.cpan.org/src/5.0/perl5.005_04.tar.gz>
  perl5.004_05      URL: <http://www.cpan.org/src/5.0/perl5.004_05.tar.gz>
    perl-5.8.9      URL: <http://www.cpan.org/src/5.0/perl-5.8.9.tar.gz>
    perl-5.6.2      URL: <http://www.cpan.org/src/5.0/perl-5.6.2.tar.gz>
   perl-5.24.0      URL: <http://www.cpan.org/src/5.0/perl-5.24.0.tar.gz>
   perl-5.22.2      URL: <http://www.cpan.org/src/5.0/perl-5.22.2.tar.gz>
   perl-5.20.3      URL: <http://www.cpan.org/src/5.0/perl-5.20.3.tar.gz>
   perl-5.18.4      URL: <http://www.cpan.org/src/5.0/perl-5.18.4.tar.gz>
   perl-5.16.3      URL: <http://www.cpan.org/src/5.0/perl-5.16.3.tar.gz>
   perl-5.14.4      URL: <http://www.cpan.org/src/5.0/perl-5.14.4.tar.gz>
   perl-5.12.5      URL: <http://www.cpan.org/src/5.0/perl-5.12.5.tar.gz>
   perl-5.10.1      URL: <http://www.cpan.org/src/5.0/perl-5.10.1.tar.gz>
  cperl-5.25.2      URL: <https://github.com//perl11/cperl/releases/download/cperl-5.25.2>
  cperl-5.25.1      URL: <https://github.com//perl11/cperl/releases/download/cperl-5.25.1>
  cperl-5.24.2      URL: <https://github.com//perl11/cperl/releases/download/cperl-5.24.2>
  cperl-5.24.1      URL: <https://github.com//perl11/cperl/releases/download/cperl-5.24.1>
OUT
    };
};

describe "available command output, when something installed locally," => sub {
    it "should display a list of perl versions, with markers on installed versions" => sub {
        my $app = App::perlbrew->new("available");


        my @installed_perls = (
            { name => "perl-5.24.0" },
            { name => "perl-5.20.3" }
        );

         $app->expects( 'available_perls_with_urls' )->returns( \%available_perls );
         $app->expects("installed_perls")->returns(@installed_perls);

        stdout_is sub { $app->run(); }, <<OUT

  perl5.005_04      URL: <http://www.cpan.org/src/5.0/perl5.005_04.tar.gz>
  perl5.004_05      URL: <http://www.cpan.org/src/5.0/perl5.004_05.tar.gz>
    perl-5.8.9      URL: <http://www.cpan.org/src/5.0/perl-5.8.9.tar.gz>
    perl-5.6.2      URL: <http://www.cpan.org/src/5.0/perl-5.6.2.tar.gz>
i  perl-5.24.0      URL: <http://www.cpan.org/src/5.0/perl-5.24.0.tar.gz>
   perl-5.22.2      URL: <http://www.cpan.org/src/5.0/perl-5.22.2.tar.gz>
i  perl-5.20.3      URL: <http://www.cpan.org/src/5.0/perl-5.20.3.tar.gz>
   perl-5.18.4      URL: <http://www.cpan.org/src/5.0/perl-5.18.4.tar.gz>
   perl-5.16.3      URL: <http://www.cpan.org/src/5.0/perl-5.16.3.tar.gz>
   perl-5.14.4      URL: <http://www.cpan.org/src/5.0/perl-5.14.4.tar.gz>
   perl-5.12.5      URL: <http://www.cpan.org/src/5.0/perl-5.12.5.tar.gz>
   perl-5.10.1      URL: <http://www.cpan.org/src/5.0/perl-5.10.1.tar.gz>
  cperl-5.25.2      URL: <https://github.com//perl11/cperl/releases/download/cperl-5.25.2>
  cperl-5.25.1      URL: <https://github.com//perl11/cperl/releases/download/cperl-5.25.1>
  cperl-5.24.2      URL: <https://github.com//perl11/cperl/releases/download/cperl-5.24.2>
  cperl-5.24.1      URL: <https://github.com//perl11/cperl/releases/download/cperl-5.24.1>
OUT
    };
};

runtests unless caller;
