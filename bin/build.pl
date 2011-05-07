#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

open OUT, ">", "perlbrew";

print OUT "#!/usr/bin/env perl\n";
print OUT `fatpack file`;
print OUT `cat bin/perlbrew`;

close(OUT);
chmod 0755, "perlbrew";
