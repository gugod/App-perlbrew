#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require 'test_helpers.pl';

use Test::More;
use Test::Exception;

for (qw(curl wget fetch)) {
    $App::perlbrew::HTTP_USER_AGENT_PROGRAM = "curl";
    is App::perlbrew::http_user_agent_program(), "curl";
}

$App::perlbrew::HTTP_USER_AGENT_PROGRAM = "something-that-is-not-recognized";
dies_ok {
    App::perlbrew::http_user_agent_program();
} "should die when asked to use unrecognized http UA program";

done_testing;
