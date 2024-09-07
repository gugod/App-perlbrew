#!/usr/bin/env perl
use Test2::V0;
use Test2::Tools::Spec;
use File::Temp 'tempdir';

use App::perlbrew;
use App::Perlbrew::HTTP qw(http_user_agent_program http_get http_download);

use FindBin;
use lib $FindBin::Bin;
use PerlbrewTestHelpers qw( read_file );

unless ($ENV{PERLBREW_DEV_TEST}) {
    skip_all <<REASON;

This test invokes HTTP request to external servers and should not be ran in
blind. Whoever which to test this need to set PERLBREW_DEV_TEST env var to 1.

REASON
}

my $ua = http_user_agent_program();
note "User agent program = $ua";

describe "http_get function" => sub {
    my ($output);

    before_all 'http_get' => sub {
        http_get(
            "https://get.perlbrew.pl",
            undef,
            sub { $output = $_[0]; }
        );
    };

    it "calls the callback to assign content to \$output", sub {
       ok defined($output) && length($output) > 0;
    };

    it "seems to download the correct content", sub {
        ok $output =~ m<\A #!/usr/bin/perl\n >x;
        ok $output =~ m< \$fatpacked\{"App/perlbrew.pm"\} >x;
    };
};

describe "http_download function, downloading the perlbrew-installer." => sub {
    my ($dir, $output, $download_error);

    before_all 'cleanup' => sub {
        $dir = tempdir( CLEANUP => 1 );
        $output = "$dir/perlbrew-installer";

        if (-f $output) {
            plan skip_all => <<REASON;

We created a temporary dir $dir for storing the downloaded content.
But somehow the target file name already exists before we start.
Therefore we cannot proceed the test.

REASON
        }

        my $download_error = http_download("https://install.perlbrew.pl", $output);
    };

    it "downloads to the wanted path" => sub {
        ok(-f $output);
    };

    it "seems to be downloading the right content" => sub {
        my $content = read_file($output);
        my ($first_line, undef) = split /\n/, $content, 2;
        is ($first_line, "#!/bin/sh");
    };
};

done_testing();
