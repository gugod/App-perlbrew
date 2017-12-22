use warnings;
use strict;
use Test::More;
use Test::Exception;
use App::perlbrew;

my @long_path = qw(this is a long path to check if it is joined ok);
unshift(@long_path, '');
is(App::perlbrew::joinpath(@long_path), '/this/is/a/long/path/to/check/if/it/is/joined/ok', 'we got the expected path');
dies_ok {App::perlbrew::joinpath(@long_path)} 'dies if a undefined parameter is received';
done_testing;
