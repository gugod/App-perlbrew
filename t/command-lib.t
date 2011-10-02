#!/usr/bin/env perl
use strict;
use warnings;
use File::Temp qw( tempdir );
use Test::Spec;
use Test::Output;
use App::perlbrew;

$App::perlbrew::PERLBREW_ROOT = tempdir( CLEANUP => 1 );
$App::perlbrew::PERLBREW_HOME = tempdir( CLEANUP => 1 );

describe "lib command," => sub {
    it "shows a page of usage synopsis when no sub-command are given." => sub {
        stdout_like {
            App::perlbrew->new("lib")->run;

        } qr/usage/i;
    };
};

runtests unless caller;

