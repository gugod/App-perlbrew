my $author = ((grep{ $_ eq '--author' } @ARGV) or -d '.git' && `git remote -v` =~ /git\@github/);
print STDERR "Running as an author mode!\n" if $author;

# Author: perl Makefile.PL packs App/perlbrew.pm to perlbrew
if ($author) {
    open CODE, "< lib/App/perlbrew.pm";
    local $/ = undef;
    my $code = <CODE>;
    $code =~ s/(\n__END__\n.*\Z)/\n/ms;
    my $pod = $1;

    open OUT, "> perlbrew";
    local $, = "\n";
    print OUT "#!/usr/bin/env perl",
        '# DO NOT EDIT -- this is an auto generated file',
        $code,
        'package main;',
        'App::perlbrew->run_command(@ARGV);', "\n";
}

use inc::Module::Install;

all_from 'lib/App/perlbrew.pm';

requires 'LWP'        => 5.828;
# requires 'local::lib' => 1.004009;

install_script 'bin/perlbrew';

tests 't/*.t';

WriteAll;
