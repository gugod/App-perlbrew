my $author = ((grep{ $_ eq '--author' } @ARGV) or -d '.git' && `git remote -v` =~ /git\@github/);
print STDERR "Running as an author mode!\n" if $author;

sub slurp { 
    my $file = shift;
    open CODE, '<', $file;
    local $/ = undef;
    my $code = <CODE>;
    return $code;
}

sub embed {
    my $package = shift;
    my $code = slurp(
        -f $package ? $package : do {
            $package =~ s{::}{/}g;
            $package .= ".pm";
            $INC{$package};
        }
    );
    $code =~ s/(\n__END__\n.*\Z)/\n/ms;
    $code =~ s/(\n__DATA__\n.*\Z)/\n/ms;
    $code .= "\n\$INC{'$package'} = __FILE__;\n";
    return $code;
}

# Author: perl Makefile.PL packs App/perlbrew.pm to perlbrew
if ($author) {
    unshift @INC, "lib";
    require App::perlbrew;
    require HTTP::Lite;

    my $script = slurp 'bin/perlbrew';

    open OUT, "> perlbrew";
    local $, = "\n";
    print OUT "#!/usr/bin/env perl",
        '# DO NOT EDIT -- this is an auto generated file',
        embed('HTTP::Lite'),
        embed('App::perlbrew'),
        'package main;',
        slurp('bin/perlbrew');
}

use inc::Module::Install;

license 'perl';
all_from 'lib/App/perlbrew.pm';

requires 'HTTP::Lite'   => 2.2;
# requires 'local::lib' => 1.004009;

install_script 'bin/perlbrew';

tests 't/*.t';

WriteAll;
