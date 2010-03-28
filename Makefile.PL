use strict;
my $author = ((grep{ $_ eq '--author' } @ARGV) or -d '.git' && `git remote -v` =~ /git\@github/);
print STDERR "Running as an author mode!\n" if $author;

# Author: perl Makefile.PL packs App/perlbrew.pm to perlbrew
if ($author) {
    my @mtime = map { (stat $_)[9] } qw(perlbrew Makefile.PL bin/perlbrew lib/App/perlbrew.pm);

    my $x = shift @mtime;
    if (grep { $_ > $x } @mtime) {
        print STDERR "Building 'perlbrew' executable.\n";
        system("pp -I lib -o perlbrew -P bin/perlbrew") == 0
            or warn("... Failed. Make sure PAR is installed to pack perlbrew executable.");
        print STDERR "perlbrew executable is rebuilt\n";
    }
}

use inc::Module::Install;

license 'perl';
all_from 'lib/App/perlbrew.pm';

requires 'HTTP::Lite'   => 2.2;
# requires 'local::lib' => 1.004009;

install_script 'bin/perlbrew';

tests 't/*.t';

WriteAll;
