#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;

use App::Perlbrew::HTTP qw(http_user_agent_program);

use Test::More;
use Test::Exception;

for my $prog (qw(curl wget fetch)) {
    subtest "UA set to $prog", sub {
        local $App::Perlbrew::HTTP::HTTP_USER_AGENT_PROGRAM = $prog;
        is http_user_agent_program(), $prog, "UA Program can be set to: $prog";
    };
}

subtest "something not supported", sub {
    local $App::Perlbrew::HTTP::HTTP_USER_AGENT_PROGRAM = "something-that-is-not-recognized";
    dies_ok {
        http_user_agent_program();
    } "should die when asked to use unrecognized http UA program";
};

done_testing;
