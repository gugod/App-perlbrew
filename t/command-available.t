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
# This is an example of availables perls on fluca1978 machine 2017-10-05.
#
my %available_perls = (
   'perl-5.27.4'      => 'http://www.cpan.org/src/5.0/perl-5.27.4.tar.gz',
   'perl-5.26.1'      => 'http://www.cpan.org/src/5.0/perl-5.26.1.tar.gz',
   'perl-5.24.3'      => 'http://www.cpan.org/src/5.0/perl-5.24.3.tar.gz',
   'perl-5.22.4'      => 'http://www.cpan.org/src/5.0/perl-5.22.4.tar.gz',
   'perl-5.20.3'      => 'http://www.cpan.org/src/5.0/perl-5.20.3.tar.gz',
   'perl-5.18.4'      => 'http://www.cpan.org/src/5.0/perl-5.18.4.tar.gz',
   'perl-5.16.3'      => 'http://www.cpan.org/src/5.0/perl-5.16.3.tar.gz',
   'perl-5.14.4'      => 'http://www.cpan.org/src/5.0/perl-5.14.4.tar.gz',
   'perl-5.12.5'      => 'http://www.cpan.org/src/5.0/perl-5.12.5.tar.gz',
   'perl-5.10.1'      => 'http://www.cpan.org/src/5.0/perl-5.10.1.tar.gz',
    'perl-5.8.9'      => 'http://www.cpan.org/src/5.0/perl-5.8.9.tar.gz',
    'perl-5.6.2'      => 'http://www.cpan.org/src/5.0/perl-5.6.2.tar.gz',
  'perl5.005_04'      => 'http://www.cpan.org/src/5.0/perl5.005_04.tar.gz',
  'perl5.004_05'      => 'http://www.cpan.org/src/5.0/perl5.004_05.tar.gz',
  'cperl-5.26.1'      => 'https://github.com/perl11/cperl/archive/cperl-5.26.1.tar.gz',
  'cperl-5.27.1'      => 'https://github.com/perl11/cperl/archive/cperl-5.27.1.tar.gz',
    );


describe "available command output, when nothing installed locally," => sub {
    it "should display a list of perl versions" => sub {
        my $app = App::perlbrew->new("available");
        $app->expects( 'available_perls_with_urls' )->returns( \%available_perls );

        stdout_like sub { $app->run(); }, qr/^\s{3,}c?perl-?\d\.\d{1,3}[_.]\d{1,2}\s+(available from)\s+<https?:\/\/.+>/, 'Cannot find Perl in output'
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
        stdout_like sub { $app->run(); }, qr/^i?\s{2,}c?perl-?\d\.\d{1,3}[_.]\d{1,2}\s+(INSTALLED on .* via|available from)\s+<https?:\/\/.+>/, 'Cannot find Perl in output'
    };
};

runtests unless caller;
