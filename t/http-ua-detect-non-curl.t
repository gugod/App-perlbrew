#!/usr/bin/env perl
use Test2::V0;

use FindBin qw($Bin);
BEGIN {
    $ENV{PATH} = "$Bin/fake-bin:" . $ENV{PATH};
}

use File::Which qw(which);
use App::Perlbrew::HTTP qw(http_user_agent_program);

chmod 0755, "$Bin/fake-bin/curl";

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

if ($expected_ua) {
    my $detected_ua = http_user_agent_program();
    is $detected_ua, $expected_ua, "UA: $detected_ua";
} else {
    pass("Neither wget nor fetch can be found. This test requires at least one of them to be there.");
}

done_testing;
