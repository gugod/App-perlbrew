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
        like $url, qr/cpanm$/, "GET cpanm url: $url";
        return "#!/usr/bin/env perl\n# The content of cpanm";
    }
}

describe "App::perlbrew->install_cpanm" => sub {
    it "should produce 'cpanm' in the bin dir" => sub {
        my $app = App::perlbrew->new("install-cpanm", "-q");
        $app->run();

        my $cpanm = App::Perlbrew::Path->new ($perlbrew_root, "bin", "cpanm");
        ok -f $cpanm, "cpanm is produced. $cpanm";
        ok -x $cpanm, "cpanm should be an executable.";
    };
};

done_testing;
