use strict;
use warnings;

package App::Perlbrew::Path::Installations;

require App::Perlbrew::Path;
require App::Perlbrew::Path::Installation;

our @ISA = qw( App::Perlbrew::Path );

sub child {
    my ($self, @params) = @_;

    my $return = $self;
    $return = $return->_child('App::Perlbrew::Path::Installation' => shift @params) if @params;
    $return = $return->child(@params) if @params;

    $return;
}

sub children {
    shift->_children('App::Perlbrew::Path::Installation' => @_);
}

sub list {
    shift->children;
}

1;

