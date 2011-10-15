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

describe "available command output, when nothing installed locally," => sub {
    it "should display a list of perl versions" => sub {
        my $app = App::perlbrew->new("available");

        my @available_perls = qw(perl-5.14.1 perl-5.14.2 perl-5.12.4);

        $app->expects("available_perls")->returns(@available_perls);

        stdout_is sub {
            $app->run();
        }, <<OUT
  perl-5.14.1
  perl-5.14.2
  perl-5.12.4
OUT
    };
};

describe "available command output, when something installed locally," => sub {
    it "should display a list of perl versions, with markers on installed versions" => sub {
        my $app = App::perlbrew->new("available");

        my @available_perls = qw(perl-5.14.1 perl-5.14.2 perl-5.12.4);
        my @installed_perls = (
            { name => "perl-5.14.1" },
            { name => "perl-5.14.2" }
        );

        $app->expects("available_perls")->returns(@available_perls);
        $app->expects("installed_perls")->returns(@installed_perls);

        stdout_is sub {
            $app->run();
        }, <<OUT
i perl-5.14.1
i perl-5.14.2
  perl-5.12.4
OUT
    };
};

runtests unless caller;
