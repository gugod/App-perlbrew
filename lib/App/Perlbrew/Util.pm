package App::Perlbrew::Util;
use strict;
use warnings;
use 5.008;

use Exporter 'import';
our @EXPORT = qw(uniq min editdist files_are_the_same perl_version_to_integer);

sub uniq {
    my %seen;
    grep { !$seen{$_}++ } @_;
}

sub min(@) {
    my $m = $_[0];
    for(@_) {
        $m = $_ if $_ < $m;
    }
    return $m;
}

# straight copy of Wikipedia's "Levenshtein Distance"
sub editdist {
    my @a = split //, shift;
    my @b = split //, shift;

    # There is an extra row and column in the matrix. This is the
    # distance from the empty string to a substring of the target.
    my @d;
    $d[$_][0] = $_ for (0 .. @a);
    $d[0][$_] = $_ for (0 .. @b);

    for my $i (1 .. @a) {
        for my $j (1 .. @b) {
            $d[$i][$j] = ($a[$i-1] eq $b[$j-1] ? $d[$i-1][$j-1]
                : 1 + min($d[$i-1][$j], $d[$i][$j-1], $d[$i-1][$j-1]));
        }
    }

    return $d[@a][@b];
}

sub files_are_the_same {
    ## Check dev and inode num. Not useful on Win32.
    ## The for loop should always return false on Win32, as a result.

    my @files = @_;
    my @stats = map {[ stat($_) ]} @files;

    my $stats0 = join " ", @{$stats[0]}[0,1];
    for (@stats) {
        return 0 if ((! defined($_->[1])) || $_->[1] == 0);
        unless ($stats0 eq join(" ", $_->[0], $_->[1])) {
            return 0;
        }
    }
    return 1
}

sub perl_version_to_integer {
    my $version = shift;
    my @v = split(/[\.\-_]/, $version);
    return undef if @v < 2;
    if ($v[1] <= 5) {
        $v[2] ||= 0;
        $v[3] = 0;
    }
    else {
        $v[3] ||= $v[1] >= 6 ? 9 : 0;
        $v[3] =~ s/[^0-9]//g;
    }

    return $v[1]*1000000 + $v[2]*1000 + $v[3];
}

1;
