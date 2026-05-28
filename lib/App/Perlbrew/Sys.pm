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

sub perlpath {
    # Ref: perldoc: perlvar. On $EXECUTABLE_NAME / $^X
    # https://perldoc.perl.org/perlvar#$%5EX
    return $Config{perlpath} . ( $Config{perlpath} =~ m/$Config{_exe}$/i ? "" : $Config{_exe} );
}

sub arch {
    if (os() eq 'darwin' && perlpath() eq "/usr/bin/perl") {
        my $output = qx(uname -m);
        return $output;
    } else {
        return (split(/-/, $Config{myarchname}, 2))[0];
    }
}

1;
