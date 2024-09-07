#!/usr/bin/env perl
use Test2::V0;
use File::Which qw(which);
use App::Perlbrew::HTTP qw(http_user_agent_program);

my $expected_ua;
if (which("curl")) {
    $expected_ua = "curl";
}
elsif (which("wget")) {
    $expected_ua = "wget";
}
elsif (which("fetch")) {
    $expected_ua = "fetch";
}

my $detected_ua = http_user_agent_program();
is $detected_ua, $expected_ua, "UA: $detected_ua";

done_testing;
