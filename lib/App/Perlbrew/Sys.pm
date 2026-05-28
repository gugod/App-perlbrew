package App::Perlbrew::Sys;
use strict;
use warnings;
use Config;
use Capture::Tiny qw(capture);

sub osname {
    $Config{osname}
}

sub archname {
    $Config{archname}
}

sub os {
    $Config{osname}
}

sub _uname_m {
    my $uname = qx(uname -m 2 >/dev/null);
    chomp($uname);
    return $uname;
}

sub arch {
    if (os() eq 'darwin') {
        return _uname_m();
    } else {
        return (split(/-/, $Config{myarchname}, 2))[0];
    }
}

1;
