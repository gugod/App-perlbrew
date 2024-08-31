package PerlbrewTestHelpers;
use Test2::V0;
use Test2::Plugin::IOEvents;

use Exporter 'import';
our @EXPORT_OK = qw(stdout_from stdout_is stdout_like);

# Replacements of Test::Output made by using Test2::Plugin::IOEvents

sub stdout_from (&) {
    my ($cb) = @_;
    my $events = intercept { $cb->() };
    return join "", map { $_->details } grep { $_->tag eq 'STDOUT' } map { @{ $_->facets->{info} } }@$events;
}

sub stdout_is (&$;$) {
    my ($cb, $expected, $desc) = @_;
    is(stdout_from(sub { $cb->() }), $expected, $desc);
}

sub stdout_like (&$;$) {
    my ($cb, $re, $desc) = @_;
    like(stdout_from(sub { $cb->() }), $re, $desc);
}


1;
