my $author = ((grep{ $_ eq '--author' } @ARGV) or -d '.git' && `git remote -v` =~ /git\@github/);
print STDERR "Running as an author mode!\n" if $author;

sub slurp { 
    my $file = shift;
    open CODE, '<', $file;
    local $/ = undef;
    my $code = <CODE>;
    return $code;
}

# Author: perl Makefile.PL packs App/perlbrew.pm to perlbrew
if ($author) {
    my $code = slurp 'lib/App/perlbrew.pm';
    $code =~ s/(\n__END__\n.*\Z)/\n/ms;
    
    my $script = slurp 'bin/perlbrew';

    open OUT, "> perlbrew";
    local $, = "\n";
    print OUT "#!/usr/bin/env perl",
        '# DO NOT EDIT -- this is an auto generated file',
        $code,
        'package main;',
        $script
}

use inc::Module::Install;

all_from 'lib/App/perlbrew.pm';

requires 'HTTP::Lite'   => 2.2;
# requires 'local::lib' => 1.004009;

install_script 'bin/perlbrew';

tests 't/*.t';

WriteAll;
