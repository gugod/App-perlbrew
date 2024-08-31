#!/usr/bin/env perl
use Test2::V0;
use File::Temp qw(tempdir);

use FindBin;
use lib $FindBin::Bin;
use PerlbrewTestHelpers qw(write_file);

use App::Perlbrew::HTTP qw(http_download);

subtest "http_download: dies when when the download target already exists" => sub {
    my $dir    = tempdir( CLEANUP => 1 );
    my $output = "$dir/whatever";

    write_file($output, "so");

    my $error;
    like(
        dies {
            my $error = http_download( "https://install.perlbrew.pl", $output );
        },
        qr(^ERROR: The download target < \Q$output\E > already exists\.$),
        'dies with the expected error message'
    );
};

done_testing;
