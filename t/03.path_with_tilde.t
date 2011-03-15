#!perl
use strict;
use Test::More tests => 2;

use App::perlbrew;

my $app = App::perlbrew->new();

my $home = $app->env("HOME");

is $app->path_with_tilde("$home/foo/bar"), "~/foo/bar";
is $app->path_with_tilde("/baz/foo/bar"),  "/baz/foo/bar";
