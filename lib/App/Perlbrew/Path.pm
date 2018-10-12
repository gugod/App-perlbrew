
use strict;
use warnings;

package App::Perlbrew::Path;

require File::Path;

use overload (
	'""' => \& stringify,
	fallback => 1,
);

sub _joinpath {
    for my $entry(@_) {
        no warnings 'uninitialized';
        die 'Received an undefined entry as a parameter (all parameters are: '. join(', ', @_). ')' unless (defined($entry));
    }
    return join "/", @_;
}

sub new {
	my ($class, @path) = @_;

	bless { path => _joinpath (@path) }, $class;
}

sub child {
	my ($self, @path) = @_;

	return __PACKAGE__->new ($self->{path}, @path);
}

sub mkpath {
	my ($self) = @_;
    File::Path::mkpath ([$self->stringify], 0, 0777);
	return $self;
}

sub readlink {
	my ($self) = @_;

	my $link = readlink $self->stringify;
	$link = __PACKAGE__->new ($link) if defined $link;

	return $link;
}

sub rmpath {
	my ($self) = @_;
    File::Path::rmtree([$self->stringify], 0, 0);
	return $self;
}

sub stringify {
	my ($self) = @_;

	return $self->{path};
}

1;

