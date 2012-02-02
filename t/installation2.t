#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require 'test_helpers.pl';

use Test::Spec;

## setup

##

note "PERLBREW_ROOT set to $ENV{PERLBREW_ROOT}";

describe "App::perlbrew" => sub {
    describe "->do_install_url method" => sub {
        it "should accept an URL to perl tarball, and download the tarball." => sub {
            my $app = App::perlbrew->new;

            my @expectations;
            push @expectations, App::perlbrew->expects("http_get")->returns("Not going to GET it!");
            push @expectations, $app->expects("do_extract_tarball")->returns("");
            push @expectations, $app->expects("do_install_this")->returns("");

            $app->do_install_url("http://example.com/perl-5.14.0.tar.gz");

            for(@expectations) {
                ok $_->verify;
            }
            pass;
        }
    };

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
