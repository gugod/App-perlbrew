#!/usr/bin/env perl
use Test2::V0;
use App::perlbrew;

plan 6;

my $current_shell = (split("/", $ENV{SHELL}))[-1];
my $self = App::perlbrew->new();
is($self->current_shell(), $current_shell, 'current_shell gives the expected shell based on $SHELL environment variable') or diag("\$SHELL = $ENV{SHELL}");
is($self->current_shell('foobar'), 'foobar', 'current_shell setups and returns anything passed as parameter');

for my $shell (qw(bash zsh)) {
    note("Testing with $shell");
    $self->current_shell($shell);
    ok($self->current_shell_is_bashish(), 'current_shell_is_bashish() returns true if the current shell is Bash or based on it');
}


for my $shell (qw(ksh sh)) {
    note("Testing with $shell");
    $self->current_shell($shell);
    ok( (! $self->current_shell_is_bashish()), 'current_shell_is_bashish() returns false');
}

