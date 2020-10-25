use strict;
use warnings;

package App::Perlbrew::Path::Installation;

require App::Perlbrew::Path;

our @ISA = qw( App::Perlbrew::Path );

sub name {
    $_[0]->basename;
}

sub bin {
    shift->child(bin => @_);
}

sub man {
    shift->child(man => @_);
}

sub perl {
    shift->bin('perl');
}

sub version_file {
    shift->child('.version');
}

1;

