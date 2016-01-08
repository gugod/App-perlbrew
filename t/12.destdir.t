#!perl
use strict;
use Path::Class;
use Capture::Tiny qw/capture/;
use IO::All;
use App::perlbrew;
use File::Temp qw( tempdir );

$App::perlbrew::PERLBREW_ROOT = tempdir( CLEANUP => 1 );
$App::perlbrew::PERLBREW_HOME = tempdir( CLEANUP => 1 );
$ENV{PERLBREW_ROOT} = $App::perlbrew::PERLBREW_ROOT;
my $DESTDIR = tempdir( CLEANUP => 1 );

use Test::More;

## setup

App::perlbrew::rmpath( $ENV{PERLBREW_ROOT} );

## mock

no warnings 'redefine';

sub App::perlbrew::do_system {
    my ($self, $cmd) = @_;
    if ($cmd =~ /sitelib/) {
        print "sitelib='$ENV{PERLBREW_ROOT}/perls/perl-5.14.2/lib/site_perl/5.14.2';\n";
        print "installprefix='$ENV{PERLBREW_ROOT}/perls/perl-5.14.2';\n";
        print "installstyle='lib';\n";
        return 1;
    }
    elsif ($cmd =~ /Configure/) {
        # pretend to succeed
        return 1;
    }
    else {
        # fail to run
        $? = 1<<8;
        $! = "Could not run '$cmd'";
        return 0;
    }
}

sub App::perlbrew::do_install_release {
    my ($self, $dist) = @_;
    my ($dist_name, $dist_version) = $dist =~ m/^(.*)-([\d.]+(?:-RC\d+)?)$/;

    my $name = $dist;
    $name = $self->{as} if $self->{as};

    my $root = dir($DESTDIR, $ENV{PERLBREW_ROOT});
    my $installation_dir = $root->subdir("perls", $name);
    App::perlbrew::mkpath($installation_dir);
    App::perlbrew::mkpath($root->subdir("perls", $name, "bin"));

    my $perl = $root->subdir("perls", $name, "bin")->file("perl");
    io($perl)->print("#!/bin/sh\nperl \"\$@\";\n");
    chmod 0755, $perl;

    # fake the install
    $self->do_install_this("/tmp/fake-src/perl-5.14.2", $dist_version, $dist);
}

use warnings;

## main

note "PERLBREW_ROOT set to $ENV{PERLBREW_ROOT}";
note "DESTDIR set to $DESTDIR";

subtest "No perls yet installed" => sub {
    my $app = App::perlbrew->new;
    my @installed = grep { !$_->{is_external} } $app->installed_perls;
    is 0+@installed, 0, "no perls installed";
};

subtest "--destdir option can be set" => sub {
    my $app = App::perlbrew->new('install', 'perl-5.14.2',
        '--destdir=/tmp/foo'
    );

    is join(' ', $app->args), join(' ', qw(install perl-5.14.2)), "post-option args correct";
    is $app->{destdir}, '/tmp/foo', '--destdir set as expected';
};

subtest "mock installing" => sub {
    my $sitefile = File::Temp->new;
    print $sitefile "use strict;\n";
    close $sitefile;
    my $app = App::perlbrew->new('install', 'perl-5.14.2',
        "--destdir=$DESTDIR", "--sitecustomize=$sitefile"
    );
    my ($output,$error) = capture { $app->run };

    my @installed = grep { !$_->{is_external} } $app->installed_perls;
use Data::Dumper; print Dumper \@installed;
    is 0+@installed, 0, "found 0 installed perl (as it's installed in DESTDIR)";

    my $root = dir($DESTDIR, $ENV{PERLBREW_ROOT});
    my $perldir = $root->subdir("perls", "perl-5.14.2");
    my $installedsite = $perldir->file('lib', 'site_perl', '5.14.2', 'sitecustomize.pl');
    ok( -f $installedsite, "sitecustomize.pl installed in DESTDIR" );

    my $guts = do { local (@ARGV, $/) = $installedsite; <> };
    is( $guts, "use strict;\n", "sitecustomize.pl contents correct in DESTDIR" );
};

done_testing;
# vim: ts=4 sts=4 sw=4 et:
