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
        like $url, qr/patchperl$/, "GET patchperl url: $url";
        return "#!/usr/bin/env perl\n# The content of patchperl";
    }
}

describe "App::perlbrew->install_patchperl" => sub {
    it "should produce 'patchperl' in the bin dir" => sub {
        my $app = App::perlbrew->new("install-patchperl", "-q");
        $app->run();

        my $patchperl = App::Perlbrew::Path->new ($perlbrew_root, "bin", "patchperl");
        ok -f $patchperl, "patchperl is produced. $patchperl";
        ok -x $patchperl, "patchperl should be an executable.";
    };
};

done_testing;
