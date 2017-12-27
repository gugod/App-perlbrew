use warnings;
use strict;
use Test::More tests => 3;
use Test::Exception;
use App::perlbrew;

my @long_path = qw(this is a long path to check if it is joined ok);
unshift(@long_path, '');
is(App::perlbrew::joinpath(@long_path), '/this/is/a/long/path/to/check/if/it/is/joined/ok', 'we got the expected path');
$long_path[3] = undef;
dies_ok { App::perlbrew::joinpath(@long_path) } 'dies if a undefined parameter is received';
like($@, qr/^Received an undefined entry as a parameter/, 'dies with expected message');
