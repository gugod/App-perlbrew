use warnings;
use strict;
use Test::More tests => 6;
use App::perlbrew;
use Test::TempDir::Tiny 0.016;

my $dir = tempdir();
mkdir("$dir/build");
mkdir("$dir/build/blead");
touch( "$dir/build/blead", 'OYFTV_51234' );
touch( "$dir/build/blead", 'Hwefwo8124' );
touch( "$dir/build/blead", 'perl-blead-hsf743r' );
my $blead = 'perl-blead-e7e8ce8';
mkdir("$dir/build/blead/$blead");

my @content;
my $found_dir = App::perlbrew::search_blead_dir( "$dir/build", \@content );
is( $found_dir,       undef, 'no candidate directory is found' );
is( scalar(@content), 1,     'there are only directories on content cache' );
is( $content[0], 'blead', 'have the expected directory in the content cache' );
$found_dir = App::perlbrew::search_blead_dir( "$dir/build/blead", \@content );
is( $found_dir,       $blead, 'the expected directory is found' );
is( scalar(@content), 1,      'there are only directories on content cache' );
is( $content[0], $blead, 'have the expected directory in the content cache' );

# creating files to make sure search_blead_dir only considers directories
sub touch {
    my ( $dir, $file ) = @_;
    my $path = "$dir/$file";
    open( my $out, '>', $path ) or die "Cannot create $path: $!";
    print $out '...';
    close($out);
}

