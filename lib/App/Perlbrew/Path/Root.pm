
use strict;
use warnings;

package App::Perlbrew::Path::Root;

require App::Perlbrew::Path;

our @ISA = qw( App::Perlbrew::Path );

sub bin {
	shift->child (bin => @_);
}

sub build {
	shift->child (build => @_);
}

sub dists {
	shift->child (dists => @_);
}

sub etc {
	shift->child (etc => @_);
}

sub perls {
	shift->child (perls => @_);
}

1;

