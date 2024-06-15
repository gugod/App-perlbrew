#!/usr/bin/env perl
use Test2::V0;
use File::Basename qw(basename);
use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require 'test2_helpers.pl';

plan 6;

note "PERLBREW_ROOT set to $ENV{PERLBREW_ROOT}";

my $pb = App::perlbrew->new;
ok($pb, 'App::perlbrew object created');

my $test_dir = App::Perlbrew::Path->new ($pb->root, qw/build test/);
my $test_file = App::Perlbrew::Path->new ( $test_dir, 3 );
$test_dir->mkpath;
open my $out, '>', $test_file
    or die "Couldn't create $test_file: $!";

ok -e $test_file, 'Test file 3 created';
my $extracted_dir = $pb->do_extract_tarball( App::Perlbrew::Path->new ($FindBin::Bin, 'test.tar.gz') );
diag $extracted_dir;

is $extracted_dir->basename => 'test', 'Test tarball extracted as expected';

ok !-e $test_file, 'Test file 3 was unlinked by tar';
ok -e App::Perlbrew::Path->new ( $extracted_dir, $_ ), "Test file $_ exists" for 1..2;
