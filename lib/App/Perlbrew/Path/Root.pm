use strict;
use warnings;

package App::Perlbrew::Path::Root;

use App::Perlbrew::Path ();
use App::Perlbrew::Path::Installations ();

our @ISA = qw( App::Perlbrew::Path );

sub bin {
    shift->child(bin => @_);
}

sub build {
    shift->child(build => @_);
}

sub dists {
    shift->child(dists => @_);
}

sub etc {
    shift->child(etc => @_);
}

sub perls {
    my ($self, @params) = @_;

    my $return = $self->_child('App::Perlbrew::Path::Installations', 'perls');
    $return = $return->child(@params) if @params;

    return $return;
}

1;

