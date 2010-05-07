package App::perlbrew;
use strict;
use 5.8.0;
our $VERSION = "0.06";

my $ROOT = $ENV{PERLBREW_ROOT} || "$ENV{HOME}/perl5/perlbrew";
my $CURRENT_PERL = "$ROOT/perls/current";

sub run_command {
    my ( undef, $opt, $x, @args ) = @_;
    $opt->{log_file} = "$ROOT/build.log";
    my $self = bless $opt, __PACKAGE__;
    $x ||= "help";
    my $s = $self->can("run_command_$x") or die "Unknow command: `$x`. Typo?";
    $self->$s(@args);
}

sub run_command_help {
    print <<HELP;
perlbrew - $VERSION

Usage:

    # Read more help
    perlbrew -h

    perlbrew init

    perlbrew install perl-5.12.0
    perlbrew install perl-5.13.0
    perlbrew installed

    perlbrew switch perl-5.12.0
    perlbrew switch /usr/bin/perl

    perlbrew off

HELP
}

sub run_command_init {
    require File::Path;
    File::Path::mkpath($_) for (
        "$ROOT/perls", "$ROOT/dists", "$ROOT/build", "$ROOT/etc",
        "$ROOT/bin"
    );

    system <<RC;
echo 'export PATH=$ROOT/bin:$ROOT/perls/current/bin:\${PATH}' > $ROOT/etc/bashrc
echo 'setenv PATH $ROOT/bin:$ROOT/perls/current/bin:\$PATH' > $ROOT/etc/cshrc
RC

    my ( $shrc, $yourshrc );
    if ( $ENV{SHELL} =~ /(t?csh)/ ) {
        $shrc     = 'cshrc';
        $yourshrc = $1 . "rc";
    }
    else {
        $shrc = $yourshrc = 'bashrc';
    }

    print <<INSTRUCTION;
Perlbrew environment initiated, required directories are created under

    $ROOT

Well-done! Congratulations! Please add the following line to the end
of your ~/.${yourshrc}

    source $ROOT/etc/${shrc}

After that, exit this shell, start a new one, and install some fresh
perls:

    perlbrew install perl-5.12.0-RC0
    perlbrew install perl-5.10.1

For further instructions, simply run:

    perlbrew

The default help messages will popup an tell you what to do!

Enjoy perlbrew at \$HOME!!
INSTRUCTION

}

sub run_command_install {
    my ( $self, $dist, $opts ) = @_;

    unless ($dist) {
        require File::Spec;
        require File::Path;
        require File::Copy;

        my $executable = $0;

        unless (File::Spec->file_name_is_absolute($executable)) {
            $executable = File::Spec->rel2abs($executable);
        }

        my $target = File::Spec->catfile($ROOT, "bin", "perlbrew");
        if ($executable eq $target) {
            print "You are already running the installed perlbrew:\n\n    $executable\n";
            exit;
        }

        File::Path::mkpath("$ROOT/bin");
        File::Copy::copy($executable, $target);
        chmod(0755, $target);

        print <<HELP;
The perlbrew is installed as:

    $target

You may trash the downloaded $executable from now on.

Next, if this is the first time you run perlbrew installation, run:

    $target init

And follow the instruction on screen.
HELP
        return;
    }

    my ($dist_name, $dist_version) = $dist =~ m/^(.*)-([\d.]+(?:-RC\d+)?|git)$/;
    my $dist_git_describe;

    if (-d $dist && !$dist_name || !$dist_version) {
        if (-d "$dist/.git") {
            if (`git describe` =~ /v((5\.\d+\.\d+)(-\d+-\w+)?)$/) {
                $dist_name = "perl";
                $dist_git_describe = "v$1";
                $dist_version = $2;
            }
        }
        else {
            print <<HELP;

The given directory $dist is not a git checkout of perl repository. To
brew a perl from git, clone it first:

    git clone git://github.com/mirrors/perl.git
    perlbrew install perl

HELP
                return;
        }
    }

    if ($dist_name eq 'perl') {
        my ($dist_path, $dist_tarball, $dist_commit);

        unless ($dist_git_describe) {
            require HTTP::Lite;

            my $http_get = sub {
                my ($url, $cb) = @_;
                my $ua = HTTP::Lite->new;

                my $loc = $url;
                my $status = $ua->request($loc) or die "Fail to get $loc";

                my $redir_count = 0;
                while ($status == 302 || $status == 301) {
                    last if $redir_count++ > 5;
                    for ($ua->headers_array) {
                        /Location: (\S+)/ and $loc = $1, last;
                    }
                    $loc or last;
                    $status = $ua->request($loc) or die "Fail to get $loc";
                }
                if ($cb) {
                    return $cb->($ua->body);
                }
                return $ua->body;
            };

            my $html = $http_get->("http://search.cpan.org/dist/$dist");

            ($dist_path, $dist_tarball) =
                $html =~ m[<a href="(/CPAN/authors/id/.+/(${dist}.tar.(gz|bz2)))">Download</a>];

            my $dist_tarball_path = "${ROOT}/dists/${dist_tarball}";
            if (-f $dist_tarball_path) {
                print "Use the previously fetched ${dist_tarball}\n";
            }
            else {
                print "Fetching $dist as $dist_tarball_path\n";

                $http_get->(
                    "http://search.cpan.org${dist_path}",
                    sub {
                        my ($body) = @_;
                        open my $BALL, "> $dist_tarball_path";
                        print $BALL $body;
                        close $BALL;
                    }
                );
            }

        }

        my $usedevel = $dist_version =~ /5\.1[13579]|git/ ? "-Dusedevel" : "";

        my @d_options = @{ $self->{D} };
        my $as = $self->{as} || ($dist_git_describe ? "perl-$dist_git_describe" : $dist);
        unshift @d_options, qq(prefix=$ROOT/perls/$as);
        push @d_options, "usedevel" if $usedevel;
        print "Installing $dist into $ROOT/perls/$as\n";
        print <<INSTALL if $self->{quiet} && !$self->{verbose};
This would take a while. You can run the following command on another shell to track the status:

  tail -f $self->{log_file}

INSTALL

        my ($extract_command, $configure_flags) = ("", "-des");

        my $dist_extracted_dir;
        if ($dist_git_describe) {
            $extract_command = "echo 'Building perl in the git checkout dir'";
            $dist_extracted_dir = File::Spec->rel2abs( $dist );
        } else {
            $dist_extracted_dir = "$ROOT/build/${dist}";

            my $tarx = "tar " . ( $dist_tarball =~ /bz2/ ? "xjf" : "xzf" );
            $extract_command = "cd $ROOT/build; $tarx $ROOT/dists/${dist_tarball}";
            $configure_flags = '-de';
        }

        my $cmd = join ";",
        (
            $extract_command,
            "cd $dist_extracted_dir",
            "rm -f config.sh Policy.sh",
            "sh Configure $configure_flags " . join( ' ', map { "-D$_" } @d_options ),
            "make",
            (
                $self->{force}
                ? ( 'make test', 'make install' )
                : "make test && make install"
            )
        );
        $cmd = "($cmd) >> '$self->{log_file}' 2>&1 "
            if ( $self->{quiet} && !$self->{verbose} );


        print $cmd, "\n";

        delete $ENV{$_} for qw(PERL5LIB PERL5OPT);    

        print !system($cmd) ? <<SUCCESS : <<FAIL;
Installed $dist as $as successfully. Run the following command to switch to it.

  perlbrew switch $as

SUCCESS
Installing $dist failed. See $self->{log_file} to see why.
If you want to force install the distribution, try:

  perlbrew --force install $dist_name

FAIL
    }
}

sub run_command_installed {
    my $self    = shift;
    my $current = readlink("$ROOT/perls/current");

    for (<$ROOT/perls/*>) {
        next if m/current/;
        my ($name) = $_ =~ m/\/([^\/]+$)/;
        print $name, ( $name eq $current ? '(*)' : '' ), "\n";
    }

    my $current_perl_executable = readlink("$ROOT/bin/perl");
    for ( grep { -x $_ && !-l $_ } map { "$_/perl" } split(":", $ENV{PATH}) ) {
        print $_, ($current_perl_executable eq $_ ? "(*)" : ""), "\n";
    }
}

sub run_command_switch {
    my ( $self, $dist ) = @_;
    if (-x $dist) {
        unlink "$ROOT/perls/current";
        system "ln -fs $dist $ROOT/bin/perl";
        print "Switched to $dist\n";
        return;
    }

    die "${dist} is not installed\n" unless -d "$ROOT/perls/${dist}";
    unlink "$ROOT/perls/current";
    system "cd $ROOT/perls; ln -s $dist current";
    for my $executable (<$ROOT/perls/current/bin/*>) {
        my ($name) = $executable =~ m/bin\/(.+?)(5\.\d.*)?$/;
        my $target = "$ROOT/bin/${name}";
        next unless -l $target || !-e $target;
        system("ln -fs $executable $target");
    }
}

sub run_command_off {
    local $_ = "$ROOT/perls/current";
    unlink if -l;
    for my $executable (<$ROOT/bin/*>) {
        unlink($executable) if -l $executable;
    }
}

1;

__END__

=head1 NAME

App::perlbrew - Manage perl installations in your $HOME

=head1 SYNOPSIS

    # Initialize
    perlbrew init

    # Install some Perls
    perlbrew install perl-5.8.1
    perlbrew install perl-5.11.5

    # See what were installed
    perlbrew installed

    # Switch perl in the $PATH
    perlbrew switch perl-5.11.5
    perl -v

    # Switch to another version
    perlbrew switch perl-5.8.1
    perl -v

    # Switch to a certain perl executable not managed by perlbrew.
    perlbrew switch /usr/bin/perl

    # Or turn it off completely. Useful when you messed up too deep.
    perlbrew off

    # Use 'switch' command to turn it back on.
    perlbrew switch perl-5.11.5

=head1 DESCRIPTION

perlbrew is a program to automate the building and installation of
perl in the users HOME. At the moment, it installs everything to
C<~/perl5/perlbrew>, and requires you to tweak your PATH by including a
bashrc/cshrc file it provides. You then can benefit from not having
to run 'sudo' commands to install cpan modules because those are
installed inside your HOME too. It's almost like an isolated perl
environments.

=head1 INSTALLATION

The recommended way to install perlbrew is to run these statements in
your shell:

    curl -LO http://xrl.us/perlbrew
    chmod +x perlbrew
    ./perlbrew install

After that, C<perlbrew> installs itself to C<~/perl5/perlbrew/bin>,
and you should follow the instruction on screen to setup your
C<.bashrc> or C<.cshrc> to put it in your PATH.

The downloaded perlbrew is a self-contained standalone program that
embed all non-core modules it uses. It should be runnable with perl
5.8 or high versions of perls.

You may also install perlbrew from CPAN with cpan / cpanp / cpanm:

    cpan App::perlbrew

This installs 'perlbrew' into your current PATH and it is always
executed with your current perl.

=head1 USAGE

Please read the program usage by running

    perlbrew

(No arguments.) To read a more detail one:

    perlbrew -h

Alternatively, this should also do:

    perldoc perlbrew

If you messed up to much or get confused by having to many perls
installed, you can do:

    perlbrew switch /usr/bin/perl

It will make sure that your current perl in the PATH is pointing
to C</usr/bin/perl>.

As a matter of fact the C<switch> command checks whether the given
argument is an executale or not, and create a symlink named 'perl' to
it if it is. If you really want to you are able to do:

    perlbrew switch /usr/bin/perl6

But maybe not. After running this you might not be able to run
perlbrew anymore. So be careful not making mistakes there.

=head1 AUTHOR

Kang-min Liu  C<< <gugod@gugod.org> >>

=head1 COPYRIGHT

Copyright (c) 2010, Kang-min Liu C<< <gugod@gugod.org> >>.

The standalone executable contains the following modules embedded.

=over 4

=item L<HTTP::Lite>

Copyright (c) 2000-2002 Roy Hopper, 2009 Adam Kennedy.

Licensed under the same term as Perl itself.

=back

=head1 LICENCE

The MIT License

=head1 CONTRIBUTORS

Patches and code improvements were contributed by:

Tatsuhiko Miyagawa, Chris Prather, Yanick Champoux, aero, Jason May, Jesse Luehrs

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut
