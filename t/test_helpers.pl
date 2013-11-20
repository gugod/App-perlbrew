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

use Test::More;
use Path::Class;
use IO::All;
use File::Temp qw( tempdir );

$App::perlbrew::PERLBREW_ROOT = tempdir( CLEANUP => 1 );
$App::perlbrew::PERLBREW_HOME = tempdir( CLEANUP => 1 );
$ENV{PERLBREW_ROOT} = $App::perlbrew::PERLBREW_ROOT;
delete $ENV{PERLBREW_LIB};
App::perlbrew::mkpath( dir($ENV{PERLBREW_ROOT})->subdir("perls") );
App::perlbrew::mkpath( dir($ENV{PERLBREW_ROOT})->subdir("build") );
App::perlbrew::mkpath( dir($ENV{PERLBREW_ROOT})->subdir("dists") );

no warnings 'redefine';

sub App::perlbrew::do_install_release {
    my ($self, $name) = @_;

    $name = $self->{as} if $self->{as};

    my $root = dir($App::perlbrew::PERLBREW_ROOT);
    my $installation_dir = $root->subdir("perls", $name);

    $self->{installation_name} = $name;

    App::perlbrew::mkpath($installation_dir);
    App::perlbrew::mkpath($root->subdir("perls", $name, "bin"));

    my $perl = $root->subdir("perls", $name, "bin")->file("perl");
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

sub mock_perlbrew_lib_create {
    my $name = shift;
    App::perlbrew::mkpath(dir($App::perlbrew::PERLBREW_HOME, "libs", $name));
}

1;
