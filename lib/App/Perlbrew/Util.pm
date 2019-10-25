package App::Perlbrew::Util;
use strict;
use warnings;
use 5.008;

use Exporter 'import';
our @EXPORT = qw(uniq min editdist);

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

1;
