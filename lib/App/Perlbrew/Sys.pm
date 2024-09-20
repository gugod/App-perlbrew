package App::Perlbrew::Sys;
use strict;
use warnings;
use Config;

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
    (split(/-/, $Config{archname}, 2))[0]
}

1;
