#!/usr/bin/env perl
use strict;
use warnings;

use Path::Class;
BEGIN {
    $ENV{PERLBREW_ROOT} = file(__FILE__)->dir->subdir("mock_perlbrew_root");
}

use Test::Spec;

use App::perlbrew;

## setup

App::perlbrew::rmpath( $ENV{PERLBREW_ROOT} );

##

note "PERLBREW_ROOT set to $ENV{PERLBREW_ROOT}";

describe "App::perlbrew" => sub {
    describe "->do_install_archive method" => sub {
        it "accepts a path to perl tarball and perform installation process." => sub {
            my $app = App::perlbrew->new;

            my $e1 = $app->expects("do_extract_tarball")->returns("/a/fake/path/to/perl-5.12.3");
            my $e2 = $app->expects("do_install_this")->returns("");

            $app->do_install_archive("/a/fake/path/to/perl-5.12.3.tar.gz");

            ok $e1->verify, "do_extract_tarball is called";
            ok $e2->verify, "do_install_this is called";
            pass;
        }
    };

};

runtests unless caller;
