# -*- perl -*-

use strict;
use FindBin;
use Cwd qw(realpath);
use File::Spec::Functions;
use Pod::Usage;

my $perlbrew_pm = realpath catfile($FindBin::Bin, "..", "lib", "App", "perlbrew.pm");
my $perlbrew_pl = realpath catfile($FindBin::Bin, "..", "bin", "perlbrew");
my $readme      =  realpath catfile($FindBin::Bin, "..", "README");

my $out = "";
open my $fh, ">", \$out;

pod2usage(
    -exitval   => "NOEXIT",
    -verbose   => 99,
    -sections  => ["NAME", "DESCRIPTION", "INSTALLATION"],
    -input     => $perlbrew_pm,
    -output    => $fh,
    -noperldoc => 1
);

pod2usage(
    -exitval   => "NOEXIT",
    -verbose   => 99,
    -sections  => ["CONFIGURATION"],
    -input     => $perlbrew_pl,
    -output    => $fh,
    -noperldoc => 1
);

pod2usage(
    -exitval   => "NOEXIT",
    -verbose   => 99,
    -sections  => ["PROJECT DEVELOPMENT", "AUTHOR", "COPYRIGHT", "LICENSE", "DISCLAIMER OF WARRANTY"],
    -input     => $perlbrew_pm,
    -output    => $fh,
    -noperldoc => 1
);

open(my $readme_fh, ">", $readme) or die "Failed to open $readme";

print $readme_fh $out;

print "Done.\n";
