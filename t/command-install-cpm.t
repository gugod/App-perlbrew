#!/usr/bin/env perl
use Test2::V0;
use Test2::Tools::Spec;
use File::Temp qw( tempdir );

use App::perlbrew;
$App::perlbrew::PERLBREW_ROOT = my $perlbrew_root = tempdir( CLEANUP => 1 );
$App::perlbrew::PERLBREW_HOME = my $perlbrew_home = tempdir( CLEANUP => 1 );

{
    no warnings 'redefine';
    sub App::perlbrew::http_get {
        my ($url) = @_;
        like $url, qr/cpm$/, "GET cpm url: $url";
        return "#!/usr/bin/env perl\n# The content of cpm";
    }
}

describe "App::perlbrew->install_cpm" => sub {
    it "should produce 'cpm' in the bin dir" => sub {
        my $app = App::perlbrew->new("install-cpm", "-q");
        $app->run();

        my $cpm = App::Perlbrew::Path->new($perlbrew_root, "bin", "cpm");
        ok -f $cpm, "cpm is produced. $cpm";
        ok -x $cpm, "cpm should be an executable.";
    };
};

done_testing;
