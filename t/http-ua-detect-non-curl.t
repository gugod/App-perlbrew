#!/usr/bin/env perl
use strict;
use warnings;

use FindBin qw($Bin);
BEGIN {
    $ENV{PATH} = "$Bin/fake-bin:" . $ENV{PATH};
}

use File::Which qw(which);
use App::perlbrew;
use Test::More;

diag "PATH=$ENV{PATH}";

my $curl_path = which("curl");
diag "curl = $curl_path";
is $curl_path, "$Bin/fake-bin/curl";

my $expected_ua;
if (which("wget")) {
    $expected_ua = "wget";
}
elsif (which("fetch")) {
    $expected_ua = "fetch";
}

my $detected_ua = App::perlbrew::http_user_agent_program();
is $detected_ua, $expected_ua, "UA: $detected_ua";

done_testing;
