my $author = ((grep{ $_ eq '--author' } @ARGV) or -d '.git' && `git remote -v` =~ /git\@github/);

# Author: perl Makefile.PL packs App/perlbrew.pm to perlbrew
if ($author) {
    print STDERR "Running as an author mode!\n";
    unshift @INC, "lib";
    system("bin/build.pl");
}

use inc::Module::Install;

license 'mit';

all_from 'lib/App/perlbrew.pm';

repository 'git://github.com/gugod/App-perlbrew.git';

requires
    'File::Path::Tiny', => 0,
    'Devel::PatchPerl' => '0.26',
    'Cwd' => '3.26';

test_requires 'Test::Simple';
test_requires 'Test::More';
test_requires 'Test::Output';

install_script 'bin/perlbrew';

tests 't/*.t';

WriteAll;
