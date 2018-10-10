
use strict;
use warnings;

package App::Perlbrew::Path;

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

sub stringify {
	my ($self) = @_;

	return $self->{path};
}

1;

