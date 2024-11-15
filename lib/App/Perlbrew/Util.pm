package App::Perlbrew::Util;
use strict;
use warnings;
use 5.008;

use Exporter 'import';
our @EXPORT = qw( uniq min editdist files_are_the_same perl_version_to_integer );
our @EXPORT_OK = qw(
    find_similar_tokens
    looks_like_url_of_skaji_relocatable_perl
    looks_like_sys_would_be_compatible_with_skaji_relocatable_perl
    make_skaji_relocatable_perl_url
);

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

    my @v;
    if ($version eq 'blead') {
        @v = (999,999,999);
    } else {
        @v = split(/[\.\-_]/, $version);
    }
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

sub find_similar_tokens {
    my ($token, $tokens) = @_;
    my $SIMILAR_DISTANCE = 6;

    my @similar_tokens = sort { $a->[1] <=> $b->[1] } map {
        my $d = editdist( $_, $token );
        ( ( $d < $SIMILAR_DISTANCE ) ? [$_, $d] : () )
    } @$tokens;

    if (@similar_tokens) {
        my $best_score = $similar_tokens[0][1];
        @similar_tokens = map { $_->[0] } grep { $_->[1] == $best_score } @similar_tokens;
    }

    return \@similar_tokens;
}

sub looks_like_url_of_skaji_relocatable_perl  {
    my ($str) = @_;
    # https://github.com/skaji/relocatable-perl/releases/download/5.40.0.0/perl-linux-amd64.tar.gz
    my $prefix = "https://github.com/skaji/relocatable-perl/releases/download";
    my $version_re = qr/(5\.[0-9][0-9]\.[0-9][0-9]?.[0-9])/;
    my $name_re = qr/perl-(linux|darwin)-(amd64|arm64)\.tar\.gz/;
    return undef unless $str =~ m{ \Q$prefix\E / $version_re / $name_re }x;
    return {
        url => $str,
        version => $1,
        os => $2,
        arch => $3,
        original_filename => "perl-$2-$3.tar.gz",
    };
}


sub _arch_compat {
    my ($arch) = @_;
    my $compat = {
        x86_64 => "amd64",
        i386   => "amd64",
    };
    return $compat->{$arch} || $arch;
}

sub looks_like_sys_would_be_compatible_with_skaji_relocatable_perl {
    my ($detail, $sys) = @_;

    return (
        ($detail->{os} eq $sys->os)
        && (_arch_compat($detail->{arch}) eq _arch_compat($sys->arch))
    );
}

sub make_skaji_relocatable_perl_url {
    my ($str, $sys) = @_;
    if ($str =~ m/\Askaji-relocatable-perl-(5\.[0-9][0-9]\.[0-9][0-9]?.[0-9])\z/) {
        my $version = $1;
        my $os = $sys->os;
        my $arch = $sys->arch;
        $arch = "amd64" if $arch eq 'x86_64' || $arch eq 'i386';

        return "https://github.com/skaji/relocatable-perl/releases/download/$version/perl-$os-$arch.tar.gz";
    }
    return undef;
}

1;
