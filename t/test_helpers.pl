=begin yada yada

Copy this snippet to the beginning of tests:

    use FindBin;
    use lib $FindBin::Bin;
    use App::perlbrew;
    require 'test_helpers.pl';

tldr: This file should be `require`-ed after the "use App::perlbrew;" statement in
the test. It is meant to override subroutines for testing purposes and not
mess up developer's own perlbrew environment. `FindBin` should be used to
put 't/' dir to `@INC`.

=cut

use strict;
use Test::More;
use IO::All;
use File::Temp qw( tempdir );

sub dir {
    App::Perlbrew::Path->new(@_);
}

sub file {
    App::Perlbrew::Path->new(@_);
}

$App::perlbrew::PERLBREW_ROOT = tempdir( CLEANUP => 1 );
$App::perlbrew::PERLBREW_HOME = tempdir( CLEANUP => 1 );
$ENV{PERLBREW_ROOT} = $App::perlbrew::PERLBREW_ROOT;

delete $ENV{PERLBREW_LIB};
delete $ENV{PERLBREW_PERL};
delete $ENV{PERLBREW_PATH};
delete $ENV{PERLBREW_MANPATH};
delete $ENV{PERL_LOCAL_LIB_ROOT};

my $root = App::Perlbrew::Path::Root->new ($ENV{PERLBREW_ROOT});
$root->perls->mkpath;
$root->build->mkpath;
$root->dists->mkpath;

no warnings 'redefine';

sub App::perlbrew::do_install_release {
    my ($self, $name) = @_;

    $name = $self->{as} if $self->{as};

    my $root = $self->root;
    my $installation_dir = $root->perls ($name);

    $self->{installation_name} = $name;

    $installation_dir->mkpath;
    $root->perls($name, "bin")->mkpath;

    my $perl = $root->perls ($name, "bin")->child ("perl");
    io($perl)->print(<<'CODE');
#!/usr/bin/env perl
use File::Basename;
my $name = basename(dirname(dirname($0))), "\n";
$name =~ s/^perl-//;
my ($a,$b,$c) = split /\./, $name;
printf('%d.%03d%03d' . "\n", $a, $b, $c);
CODE

    chmod 0755, $perl;

    note "(mock) installed $name to $installation_dir";
}

sub mock_perlbrew_install {
    my ($name, @args) = @_;
    App::perlbrew->new(install => $name, @args)->run();
}

sub mock_perlbrew_off {
    mock_perlbrew_use("");
}

sub mock_perlbrew_use {
    my ($name) = @_;

    my %env = App::perlbrew->new()->perlbrew_env($name);

    for my $k (qw< PERLBREW_PERL PERLBREW_LIB PERLBREW_PATH PERL5LIB >) {
        if (defined $env{$k}) {
            $ENV{$k} = $env{$k};
        } else {
            delete $ENV{$k}
        }
    }
}

sub mock_perlbrew_lib_create {
    my $name = shift;
    App::Perlbrew::Path->new($App::perlbrew::PERLBREW_HOME, "libs", $name)->mkpath;
}

1;
