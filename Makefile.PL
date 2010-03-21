my $author = ((grep{ $_ eq '--author' } @ARGV) or -d '.git' && `git remote -v` =~ /git\@github/);
print STDERR "Running as an author mode!\n" if $author;

# Author: perl Makefile.PL packs App/perlbrew.pm to perlbrew
if ($author) {
    open CODE, "< lib/App/perlbrew.pm";
    local $/ = undef;
    my $code = <CODE>;
    $code =~ s/\n__END__\n.*\Z/\n/ms;

    open OUT, "> perlbrew";
    local $, = "\n";

    print OUT "#!/usr/bin/env perl",
        $code,
        'package main;',
        'App::perlbrew->run_command(@ARGV);', "\n";
}

use inc::Module::Install;

all_from 'lib/App/perlbrew.pm';
readme_pod_from 'lib/App/perlbrew.pm';
readme_from 'lib/App/perlbrew.pm';

requires 'LWP'   => 5.828;

install_script 'bin/perlbrew';

tests 't/*.t';
author_tests 'xt/*.t';

WriteAll;
