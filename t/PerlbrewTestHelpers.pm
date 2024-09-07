package PerlbrewTestHelpers;
use Test2::V0;
use Test2::Plugin::IOEvents;

use Exporter 'import';
our @EXPORT_OK = qw(
    read_file write_file
    stderr_from stderr_is stderr_like
    stdout_from stdout_is stdout_like
);

# Replacements of Test::Output made by using Test2::Plugin::IOEvents

sub ioevents_from {
    my ($cb) = @_;
    return grep { $_->tag eq 'STDOUT' || $_->tag eq 'STDERR' }
        map { @{ $_->facets->{info} } }
        @{ intercept(sub { $cb->() }) };
}

sub stderr_from (&) {
    my ($cb) = @_;
    join "", map { $_->details } grep { $_->tag eq 'STDERR' } ioevents_from($cb);
}

sub stderr_is (&$;$) {
    my ($cb, $expected, $desc) = @_;
    is(stderr_from(sub { $cb->() }), $expected, $desc);
}

sub stderr_like (&$;$) {
    my ($cb, $re, $desc) = @_;
    like(stderr_from(sub { $cb->() }), $re, $desc);
}

sub stdout_from (&) {
    my ($cb) = @_;
    return join "", map { $_->details } grep { $_->tag eq 'STDOUT' } ioevents_from($cb);
}

sub stdout_is (&$;$) {
    my ($cb, $expected, $desc) = @_;
    is(stdout_from(sub { $cb->() }), $expected, $desc);
}

sub stdout_like (&$;$) {
    my ($cb, $re, $desc) = @_;
    like(stdout_from(sub { $cb->() }), $re, $desc);
}

sub read_file {
    my ($file) = @_;
    open my $fh, '<', $file
        or die "Cannot open $file for read: $!";
    local $/ = undef;
    my $content = <$fh>;
    return $content;
}

sub write_file {
    my ($file, $content) = @_;
    open my $fh, '>', $file
        or die "Cannot open $file for write: $!";
    print $fh $content;
    close $fh;
    return;
}

1;
