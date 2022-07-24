use strict;
use warnings;

package App::Perlbrew::Path;

use File::Basename ();
use File::Glob ();
use File::Path ();

use overload (
    '""' => \& stringify,
    fallback => 1,
);

sub _joinpath {
    for my $entry (@_) {
        no warnings 'uninitialized';
        die 'Received an undefined entry as a parameter (all parameters are: '. join(', ', @_). ')' unless (defined($entry));
    }
    return join "/", @_;
}

sub _child {
    my ($self, $package, @path) = @_;

    $package->new($self->{path}, @path);
}

sub _children {
    my ($self, $package) = @_;

    map { $package->new($_) } File::Glob::bsd_glob($self->child("*"));
}

sub new {
    my ($class, @path) = @_;

    bless { path => _joinpath (@path) }, $class;
}

sub exists {
    my ($self) = @_;

    -e $self->stringify;
}

sub basename {
    my ($self, $suffix) = @_;

    return scalar File::Basename::fileparse($self, ($suffix) x!! defined $suffix);
}

sub child {
    my ($self, @path) = @_;

    return $self->_child(__PACKAGE__, @path);
}

sub children {
    my ($self) = @_;

    return $self->_children(__PACKAGE__);
}

sub dirname {
    my ($self) = @_;

    return App::Perlbrew::Path->new( File::Basename::dirname($self) );
}

sub mkpath {
    my ($self) = @_;
    File::Path::mkpath( [$self->stringify], 0, 0777 );
    return $self;
}

sub readlink {
    my ($self) = @_;

    my $link = CORE::readlink( $self->stringify );
    $link = __PACKAGE__->new($link) if defined $link;

    return $link;
}

sub rmpath {
    my ($self) = @_;
    File::Path::rmtree( [$self->stringify], 0, 0 );
    return $self;
}

sub stringify {
    my ($self) = @_;

    return $self->{path};
}

sub stringify_with_tilde {
    my ($self) = @_;
    my $path = $self->stringify;
    my $home = $ENV{HOME};
    $path =~ s!\Q$home/\E!~/! if $home;
    return $path;
}

sub symlink {
    my ($self, $destination, $force) = @_;
    $destination = App::Perlbrew::Path->new($destination) unless ref $destination;

    CORE::unlink($destination) if $force && (-e $destination || -l $destination);

    $destination if CORE::symlink($self, $destination);
}

sub unlink {
    my ($self) = @_;
    CORE::unlink($self);
}

1;

