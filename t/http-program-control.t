#!/usr/bin/env perl
use Test2::V0;
use FindBin;
use lib $FindBin::Bin;

use App::Perlbrew::HTTP qw(http_user_agent_command);

for my $prog (qw(curl wget fetch)) {
    local $App::Perlbrew::HTTP::HTTP_USER_AGENT_PROGRAM = $prog;
    for my $verbose (0, 1) {
        local $App::Perlbrew::HTTP::HTTP_VERBOSE = $verbose;

        subtest "UA should be $prog, verbosity should be $verbose", sub {
            my ($ua, $cmd) = http_user_agent_command( "get" => { "url" => "https://perlbrew.pl" });

            is $ua, $prog, "UA Program can be set to: $prog";

            unless ($prog eq "fetch") {
                my ($cmd_verbosity) = $cmd =~ m/\s(--verbose)\s/;
                is !!$cmd_verbosity, !!$verbose, "verbosity matches: [$cmd]";
            }
        }
    };
}

subtest "something not supported", sub {
    local $App::Perlbrew::HTTP::HTTP_USER_AGENT_PROGRAM = "something-that-is-not-recognized";
    ok dies { http_user_agent_program() },
        "should die when asked to use unrecognized http UA program";
};

done_testing;
