# -*- perl -*-

use strict;
use FindBin;
use Cwd qw(realpath);
use File::Spec::Functions;
use Pod::Usage;
use Pod::Markdown;

my $perlbrew_pm = realpath catfile($FindBin::Bin, "..", "lib", "App", "perlbrew.pm");
my $perlbrew_pl = realpath catfile($FindBin::Bin, "..", "bin", "perlbrew");
my $readme      =  realpath catfile($FindBin::Bin, "..", "README");
my $readme_md   =  realpath catfile($FindBin::Bin, "..", "README.md");

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

close $fh;

open(my $readme_fh, ">", $readme) or die "Failed to open $readme";

    print $readme_fh $out;

close $readme_fh;

print "Generated README.\n";

my $parser = Pod::Markdown->new( perldoc_url_prefix => 'metacpan' );

open my $in_file,  "<", $perlbrew_pm or die "Failed to open '$perlbrew_pm': $!\n";
open my $out_file, ">", $readme_md   or die "Failed to open '$perlbrew_pm': $!\n";

$parser->output_fh($out_file);
$parser->parse_file($in_file);

close $out_file;
close $in_file;

print "Generated README.md.\n";