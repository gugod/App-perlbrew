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
        like $url, qr/cpanm$/, "GET cpanm url: $url";
        return "The content of cpanm";
    }
}

describe "App::perlbrew->install_cpanm" => sub {
    it "should produce 'cpanm' in the bin dir" => sub {
        my $app = App::perlbrew->new("install-cpanm", "-q");
        $app->run();

        my $cpanm = file($perlbrew_root, "bin", "cpanm")->absolute;
        ok -f $cpanm, "cpanm is produced. $cpanm";
        ok -x $cpanm, "cpanm should be an executable.";
    };
};

runtests unless caller;
