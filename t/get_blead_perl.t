use warnings;
use strict;
use Test::More tests => 2;
use App::perlbrew;
use Test::TempDir::Tiny 0.016;

my $dir = tempdir();
mkdir("$dir/build");
mkdir("$dir/build/blead");
touch( "$dir/build/blead", 'OYFTV_51234' );
touch( "$dir/build/blead", 'Hwefwo8124' );
touch( "$dir/build/blead", 'Perl-perl5-hsf743r' );
my $blead = 'Perl-perl5-e7e8ce8';
mkdir("$dir/build/blead/$blead");

my $found_dir = App::perlbrew::search_blead_dir( App::Perlbrew::Path->new ("$dir/build"));
is( $found_dir,       "$dir/build/blead/$blead", 'Found the correct directory' );

$found_dir = App::perlbrew::search_blead_dir( App::Perlbrew::Path->new ("$dir/build/blead") );
is( $found_dir,       undef, 'Nothing is found.' );

# creating files to make sure search_blead_dir only considers directories
sub touch {
    my ( $dir, $file ) = @_;
    my $path = "$dir/$file";
    open( my $out, '>', $path ) or die "Cannot create $path: $!";
    print $out '...';
    close($out);
}

