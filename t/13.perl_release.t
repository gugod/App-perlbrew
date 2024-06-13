#!/usr/bin/env perl
use Test2::V0;
use Test2::Tools::Spec;
use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require "test2_helpers.pl";

use CPAN::Perl::Releases;
use JSON::PP qw(encode_json);

describe "App::perlbrew#perl_release method" => sub {
    describe "given a valid perl version" => sub {
        it "returns the perl dist tarball file name, and its download url" => sub {
            my $app = App::perlbrew->new;

            for my $version (qw(5.14.2 5.10.1 5.10.0 5.004_05)) {
                my ($ball, $url) = $app->perl_release($version);
                like $ball, qr/perl-?${version}.tar.(bz2|gz)/;
                like $url, qr/${ball}$/;
            }
        };
    };

    describe "when the given versionis not found is CPAN::Perl::Releases" => sub {
        no warnings 'redefine';

        my $version = "5.14.2";

        my $orig_sub = \&CPAN::Perl::Releases::perl_tarballs;
        *App::perlbrew::http_get = sub {
            return encode_json({hits => {hits => [{_source =>
                {download_url => "https://cpan.metacpan.org/authors/id/SOMEONE/perl-${version}.tar.gz"}
            }]}});
        };
        *CPAN::Perl::Releases::perl_tarballs = sub {};

        my $app = App::perlbrew->new;
        my ($ball, $url) = $app->perl_release($version);
        like $ball, qr/^perl-?${version}.tar.(bz2|gz)$/, $ball;
        like $url, qr#^https?://cpan\.metacpan\.org/authors/id/SOMEONE/${ball}$#, $url;

        *CPAN::Perl::Releases::perl_tarballs = $orig_sub;
    };
};

done_testing;
