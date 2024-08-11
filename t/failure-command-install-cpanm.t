#!/usr/bin/env perl
use Test2::V0;
use Test2::Tools::Spec;
use File::Temp qw( tempdir );

use App::perlbrew;
$App::perlbrew::PERLBREW_ROOT = my $perlbrew_root = tempdir( CLEANUP => 1 );
$App::perlbrew::PERLBREW_HOME = my $perlbrew_home = tempdir( CLEANUP => 1 );

{
    no warnings 'redefine';
    sub App::perlbrew::http_get {
        my ($url) = @_;
        like $url, qr/cpanm$/, "GET cpanm url: $url";
        return "404 not found.";
    }
}

describe "App::perlbrew->install_cpanm" => sub {
    it "should no produced 'cpanm' in the bin dir, if the downloaded content seems to be invalid." => sub {
        my $error;
        my $error_produced = 0;
        eval {
            my $app = App::perlbrew->new("install-cpanm", "-q");
            $app->run();
        } or do {
            $error = $@;
            $error_produced = 1;
        };

        my $cpanm = App::Perlbrew::Path->new($perlbrew_root, "bin", "cpanm");
        ok $error_produced, "generated an error: $error";
        ok !(-f $cpanm), "cpanm is not produced. $cpanm";
    };
};

done_testing;
