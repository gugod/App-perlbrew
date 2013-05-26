#!/usr/bin/env perl
use strict;
use warnings;
use Test::Spec;
use Path::Class;
use IO::All;
use File::Temp qw( tempdir );

use App::perlbrew;
$App::perlbrew::PERLBREW_ROOT = my $perlbrew_root = tempdir( CLEANUP => 1 );
$App::perlbrew::PERLBREW_HOME = my $perlbrew_home = tempdir( CLEANUP => 1 );

{
    no warnings 'redefine';
    sub App::perlbrew::http_get {
        my ($url) = @_;
        like $url, qr/patchperl$/, "GET patchperl url: $url";
        return "Some invalid piece of text";
    }
}

describe "App::perlbrew->install_patchperl" => sub {
    it "should not produce 'patchperl' in the bin dir, if the downloaded content does not seem to be valid." => sub {
        my $patchperl = file($perlbrew_root, "bin", "patchperl")->absolute;

        my $error;
        my $produced_error = 0;
        eval {
            my $app = App::perlbrew->new("install-patchperl", "-q");
            $app->run();
        } or do {
            $error = $@;
            $produced_error = 1;
        };

        ok $produced_error, "generated an error: $error";
        ok !(-f $patchperl), "patchperl is *not* installed: $patchperl";
    };
};

runtests unless caller;
