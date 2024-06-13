#!/usr/bin/env perl
use Test2::V0;

plan 2;

# test that 'do_system' wraps 'system' correctly

our @system;
BEGIN {
  *CORE::GLOBAL::system = sub { @system = @_; };
}
use App::perlbrew;

# don't actually run() it, we just want to call do_system
my $app = App::perlbrew->new('list');

$app->do_system(qw(perl -E), 'say 42');
is \@system, [qw(perl -E), 'say 42'], 'passed all arguments to system()';

$app->do_system("perl -e 'say 42'");
is \@system, ["perl -e 'say 42'"], 'passed single string to system()';
