use warnings;
use strict;
use Test::More tests => 3;
use Test::Exception;
use App::perlbrew;

my @long_path = qw(this is a long path to check if it is joined ok);
unshift(@long_path, '');
is(App::perlbrew::splitpath('/this/is/a/long/path/to/check/if/it/is/joined/ok'), @long_path, 'we got the expected path');
dies_ok { App::perlbrew::splitpath(undef) } 'dies if a undefined parameter is received';
like($@, qr/^Cannot receive an undefined path as parameter/, 'dies with expected message');
