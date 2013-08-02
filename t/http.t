#!/usr/bin/env perl
use strict;
use Test::Spec;
use App::perlbrew;
use File::Temp 'tempdir';
use IO::All;

unless ($ENV{PERLBREW_DEV_TEST}) {
    plan skip_all => <<REASON;

This test invokes HTTP request to external servers and should not be ran in
blind. Whoever which to test this need to set PERLBREW_DEV_TEST env var to 1.

REASON
}

my $ua = App::perlbrew::http_user_agent_program();
note "User agent program = $ua";

describe "App::perlbrew::http_get function" => sub {
    my ($output);

    before all => sub {
        App::perlbrew::http_get(
            "http://get.perlbrew.pl",
            undef,
            sub { $output = $_[0]; }
        );
    };

    it "calls the callback to assign content to \$output", sub {
       ok defined($output) && length($output) > 0;
    };

    it "seems to download the correct content", sub {
        ok $output =~ m<\A #!/usr/bin/perl\n >x;
        ok $output =~ m< \$fatpacked{"App/perlbrew.pm"} >x;
    };
};

describe "App::perlbrew::http_download function, downloading the perlbrew-installer." => sub {
    my ($dir, $output, $download_error);

    before all => sub {
        $dir = tempdir( CLEANUP => 1 );
        $output = "$dir/perlbrew-installer";

        if (-f $output) {
            plan skip_all => <<REASON;

We created a temporary dir $dir for storing the downloaded content.
But somehow the target file name already exists before we start.
Therefore we cannot proceed the test.

REASON
        }

        my $download_error = App::perlbrew::http_download("http://install.perlbrew.pl", $output);
    };

    it "downloads to the wanted path" => sub {
        ok(-f $output);
    };

    it "seems to be downloading the right content" => sub {
        is(scalar(io($output)->getline), "#!/bin/sh\n");
    };
};

runtests unless caller;

