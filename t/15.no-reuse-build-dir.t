use strict;
use warnings;
use Test::More tests => 6;
use File::Spec;
use File::Basename qw(basename);
use File::Path qw(mkpath);

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require 'test_helpers.pl';

note "PERLBREW_ROOT set to $ENV{PERLBREW_ROOT}";

my $pb = new_ok('App::perlbrew');

my $test_dir = File::Spec->catdir($pb->root, qw/build test/);
my $test_file = File::Spec->catfile( $test_dir, 3 );
mkpath( $test_dir );
open my $out, '>', $test_file
    or die "Couldn't create $test_file: $!";

ok -e $test_file, 'Test file 3 created';
my $extracted_dir = $pb->do_extract_tarball( File::Spec->catfile($FindBin::Bin, 'test.tar.gz') );
is basename( $extracted_dir ) => 'test', 'Test tarball extracted as expected';
ok !-e $test_file, 'Test file 3 was unlinked by tar';
ok -e File::Spec->catfile( $test_dir, $_ ), "Test file $_ exists" for 1..2;
