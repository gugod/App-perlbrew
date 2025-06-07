package App::Perlbrew::Patchperl;
use strict;
use warnings;
use 5.008;

use App::Perlbrew::Path::Root;
use Capture::Tiny qw(capture);

use Exporter 'import';
our @EXPORT_OK = qw(maybe_patchperl);

sub maybe_patchperl {
    my App::Perlbrew::Path::Root $perlbrew_root = shift;
    return (
        maybe_patchperl_in_app_root($perlbrew_root) ||
        maybe_patchperl_in_system()
    );
}

sub maybe_patchperl_in_app_root {
    my App::Perlbrew::Path::Root $perlbrew_root = shift;
    my $patchperl = $perlbrew_root->bin("patchperl");

    if (-x $patchperl && -f _) {
        return $patchperl;
    } else {
        return undef;
    }
}

sub maybe_patchperl_in_system {
    my (undef, undef, $exit_status) = capture {
        system("patchperl --version");
    };

    if ($exit_status == 0) {
        return "patchperl"
    } else {
        return undef;
    }
}

1;
