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

sub arch {
    print STDERR "DEBUG Sys: " . os() . " " . $^X . "\n";
    if (os() eq 'darwin' && $^X eq '/usr/bin/perl') {
        my $output = qx(uname -m);
        return $output;
    } else {
        return (split(/-/, $Config{myarchname}, 2))[0]
    }
}

1;
