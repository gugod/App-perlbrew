package App::perlbrew;
use strict;
use warnings;
use 5.8.0;
use Getopt::Long ();
use File::Spec::Functions qw( catfile );

our $VERSION = "0.10";
our $CONF;

my $ROOT         = $ENV{PERLBREW_ROOT} || "$ENV{HOME}/perl5/perlbrew";
my $CONF_FILE    = catfile( $ROOT, 'Conf.pm' );
my $CURRENT_PERL = "$ROOT/perls/current";

my @GETOPT_CONFIG = (
    'pass_through',
    'no_ignore_case',
    'bundling',
);
my @GETOPT_SPEC = (
    'force|f!',
    'notest|n!',
    'quiet|q!',
    'verbose|v',
    'as=s',

    'help|?',
    'version',

    # options passed directly to Configure
    'D=s@',
    'U=s@',
    'A=s@',
);


sub new {
    my($class, @argv) = @_;

    my %opt = (
        force => 0,
        quiet => 1,

        D => [],
        U => [],
        A => [],
    );

    Getopt::Long::Configure(@GETOPT_CONFIG);
    Getopt::Long::GetOptionsFromArray(\@argv, \%opt, @GETOPT_SPEC)
        or run_command_help(1);

    # fix up the effect of 'bundling'
    foreach my $flags (@opt{qw(D U A)}) {
        foreach my $value(@{$flags}) {
            $value =~ s/^=//;
        }
    }

    $opt{args} = \@argv;
    return bless \%opt, $class;
}

sub run {
    my($self) = @_;
    $self->run_command($self->get_args);
}

sub get_current_perl {
    return $CURRENT_PERL;
}

sub get_args {
    my ( $self ) = @_;
    return @{ $self->{args} };
}

sub run_command {
    my ( $self, $x, @args ) = @_;
    $self->{log_file} ||= "$ROOT/build.log";
    if($self->{version}) {
        $x = 'version';
    }
    elsif(!$x || $self->{help}) {
        $x = 'help';
    }
    my $s = $self->can("run_command_$x") or die "Unknown command: `$x`. Typo?\n";
    $self->$s(@args);
}

sub run_command_version {
    my ( $self ) = @_;
    my $package = ref $self;
    my $version = $self->VERSION;
    print <<"VERSION";
$0  - $package/$version
VERSION
}

sub run_command_help {
    my ( $self, $status ) = @_;
    require Pod::Usage;
    Pod::Usage::pod2usage(defined $status ? $status : 1);
}

sub run_command_init {
    require File::Path::Tiny;
    File::Path::Tiny::mk($_) for (
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

    perlbrew install perl-5.12.1
    perlbrew install perl-5.10.1

For further instructions, simply run:

    perlbrew

The default help messages will popup and tell you what to do!

Enjoy perlbrew at \$HOME!!
INSTRUCTION

}

sub run_command_install {
    my ( $self, $dist, $opts ) = @_;

    unless ($dist) {
        require File::Spec;
        require File::Path::Tiny;
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

        File::Path::Tiny::mk("$ROOT/bin");
        File::Copy::copy($executable, $target);
        chmod(0755, $target);

        print <<HELP;
The perlbrew is installed as:

    $target

You may trash the downloaded $executable from now on.

Next, if this is the first time you've run perlbrew installation, run:

    $target init

And follow the instruction on screen.
HELP
        # ' <- for poor editors
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
            my $mirror = $self->conf->{mirror};
            my $header = $mirror ? { 'Cookie' => "cpan=$mirror->{url}" } : undef;
            my $html = $self->_http_get("http://search.cpan.org/dist/$dist", undef, $header);

            ($dist_path, $dist_tarball) =
                $html =~ m[<a href="(/CPAN/authors/id/.+/(${dist}.tar.(gz|bz2)))">Download</a>];

            my $dist_tarball_path = "${ROOT}/dists/${dist_tarball}";
            if (-f $dist_tarball_path) {
                print "Use the previously fetched ${dist_tarball}\n";
            }
            else {
                print "Fetching $dist as $dist_tarball_path\n";

                $self->_http_get(
                    "http://search.cpan.org${dist_path}",
                    sub {
                        my ($body) = @_;
                        open my $BALL, "> $dist_tarball_path";
                        print $BALL $body;
                        close $BALL;
                    },
                    $header
                );
            }

        }

        my @d_options = @{ $self->{D} };
        my @u_options = @{ $self->{U} };
        my $as = $self->{as} || ($dist_git_describe ? "perl-$dist_git_describe" : $dist);
        unshift @d_options, qq(prefix=$ROOT/perls/$as);
        push @d_options, "usedevel" if $dist_version =~ /5\.1[13579]|git/ ? "-Dusedevel" : "";
        print "Installing $dist into $ROOT/perls/$as\n";
        print <<INSTALL if $self->{quiet} && !$self->{verbose};
This could take a while. You can run the following command on another shell to track the status:

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

        my @install = $self->{notest} ? "make install" : ("make test", "make install");
        @install    = join " && ", @install unless($self->{force});

        my $cmd = join ";",
        (
            $extract_command,
            "cd $dist_extracted_dir",
            "rm -f config.sh Policy.sh",
            "sh Configure $configure_flags " .
                join( ' ',
                    ( map { "-D$_" } @d_options ),
                    ( map { "-U$_" } @u_options ),
                ),
            $dist_version =~ /^5\.(\d+)\.(\d+)/
                && ($1 < 8 || $1 == 8 && $2 < 9)
                    ? ("$^X -i -nle 'print unless /command-line/' makefile x2p/makefile")
                    : (),
            "make", @install
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

sub calc_installed {
    my $self    = shift;
    my $current = readlink("$ROOT/perls/current");

    my @result;

    for (<$ROOT/perls/*>) {
        next if m/current/;
        my ($name) = $_ =~ m/\/([^\/]+$)/;
        push @result, { name => $name, is_current => ($name eq $current ? 1 : 0)  };
    }

    my $current_perl_executable = readlink("$ROOT/bin/perl");
    for ( grep { -f $_ && -x $_ } map { "$_/perl" } split(":", $ENV{PATH}) ) {
        push @result, {
            name       => $_,
            is_current => ($_ eq $current_perl_executable ? 1 : 0),
        };
    }

    return @result;
}

sub run_command_installed {
    my $self = shift;
    my @installed = $self->calc_installed(@_);

    for my $installed (@installed) {
        my $name = $installed->{name};
        my $cur  = $installed->{is_current};
        print $name, ($cur ? '(*)' : ''), "\n";
    }
}

sub run_command_switch {
    my ( $self, $dist ) = @_;

    unless ( $dist ) {
        # If no args were given to switch, show the current perl.
        my $current = readlink ( -d "$ROOT/perls/current"
                                 ? "$ROOT/perls/current"
                                 : "$ROOT/bin/perl" );
        printf "Currently switched %s\n",
            ( $current ? "to $current" : 'off' );
        return;
    }

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

sub run_command_mirror {
    my($self) = @_;
    print "Fetching mirror list\n";
    my $raw = $self->_http_get("http://search.cpan.org/mirror");
    my $found;
    my @mirrors;
    foreach my $line ( split m{\n}, $raw ) {
        $found = 1 if $line =~ m{<select name="mirror">};
        next if ! $found;
        last if $line =~ m{</select>};
        if ( $line =~ m{<option value="(.+?)">(.+?)</option>} ) {
            my $url  = $1;
            (my $name = $2) =~ s/&#(\d+);/chr $1/seg;
            push @mirrors, { url => $url, name => $name };
        }
    }

    my $select;
    require ExtUtils::MakeMaker;
    MIRROR: foreach my $id ( 0..$#mirrors ) {
        my $mirror = $mirrors[$id];
        printf "[% 3d] %s\n", $id + 1, $mirror->{name};
        if ( $id > 0 ) {
            my $test = $id / 19;
            if ( $test == int $test ) {
                my $remaining = $#mirrors - $id;
                my $ask = "Select a mirror by number or press enter to see the rest "
                        . "($remaining more) [q to quit]";
                my $val = ExtUtils::MakeMaker::prompt( $ask );
                next MIRROR if ! $val;
                last MIRROR if $val eq 'q';
                $select = $val;
                if ( ! $select || $select - 1 > $#mirrors ) {
                    die "Bogus mirror ID: $select";
                }
                $select = $mirrors[$select - 1];
                die "Mirror ID is invalid" if ! $select;
                last MIRROR;
            }
        }
    }
    die "You didn't select a mirror!\n" if ! $select;
    print "Selected $select->{name} ($select->{url}) as the mirror\n";
    my $conf = $self->conf;
    $conf->{mirror} = $select;
    $self->_save_conf;
    return;
}

sub _http_get {
    my ($self, $url, $cb, $header) = @_;
    require HTTP::Lite;
    my $ua = HTTP::Lite->new;

    if ( $header && ref $header eq 'HASH') {
        foreach my $name ( keys %{ $header} ) {
            $ua->add_req_header( $name, $header->{ $name } );
        }
    }

    $ua->proxy($ENV{http_proxy}) if $ENV{http_proxy};

    my $loc = $url;
    my $status = $ua->request($loc) or die "Fail to get $loc (error: $!)";

    my $redir_count = 0;
    while ($status == 302 || $status == 301) {
        last if $redir_count++ > 5;
        for ($ua->headers_array) {
            /Location: (\S+)/ and $loc = $1, last;
        }
        last if ! $loc;
        $status = $ua->request($loc) or die "Fail to get $loc (error: $!)";
        die "Failed to get $loc (404 not found). Please try again latter." if $status == 404;
    }
    return $cb ? $cb->($ua->body) : $ua->body;
}

sub conf {
    my($self) = @_;
    $self->_get_conf if ! $CONF;
    return $CONF;
}

sub _save_conf {
    my($self) = @_;
    require Data::Dumper;
    open my $FH, '>', $CONF_FILE or die "Unable to open conf ($CONF_FILE): $!";
    my $d = Data::Dumper->new([$CONF],['App::perlbrew::CONF']);
    print $FH $d->Dump;
    close $FH;
}

sub _get_conf {
    my($self) = @_;
    print "Attempting to load conf from $CONF_FILE\n";
    if ( ! -e $CONF_FILE ) {
        local $CONF = {} if ! $CONF;
        $self->_save_conf;
    }

    open my $FH, '<', $CONF_FILE or die "Unable to open conf ($CONF_FILE): $!";
    my $raw = do { local $/; my $rv = <$FH>; $rv };
    close $FH;

    my $rv = eval $raw;
    if ( $@ ) {
        warn "Error loading conf: $@";
        $CONF = {};
        return;
    }
    $CONF = {} if ! $CONF;
    return;
}

1;

__END__

=head1 NAME

App::perlbrew - Manage perl installations in your $HOME

=head1 SYNOPSIS

    # Initialize
    perlbrew init

    # pick a prefered CPAN mirror
    perlbrew mirror

    # Install some Perls
    perlbrew install perl-5.12.1
    perlbrew install perl-5.8.1
    perlbrew install perl-5.11.5

    # See what were installed
    perlbrew installed

    # Switch perl in the $PATH
    perlbrew switch perl-5.12.1
    perl -v

    # Switch to another version
    perlbrew switch perl-5.8.1
    perl -v

    # Switch to a certain perl executable not managed by perlbrew.
    perlbrew switch /usr/bin/perl

    # Or turn it off completely. Useful when you messed up too deep.
    perlbrew off

    # Use 'switch' command to turn it back on.
    perlbrew switch perl-5.12.1

=head1 DESCRIPTION

perlbrew is a program to automate the building and installation of
perl in the users HOME. At the moment, it installs everything to
C<~/perl5/perlbrew>, and requires you to tweak your PATH by including a
bashrc/cshrc file it provides. You then can benefit from not having
to run 'sudo' commands to install cpan modules because those are
installed inside your HOME too. It's a completely separate perl
environment.

=head1 INSTALLATION

The recommended way to install perlbrew is to run these statements in
your shell:

    curl -LO http://xrl.us/perlbrew
    chmod +x perlbrew
    ./perlbrew install

After that, C<perlbrew> installs itself to C<~/perl5/perlbrew/bin>,
and you should follow the instruction on screen to setup your
C<.bashrc> or C<.cshrc> to put it in your PATH.

The directory C<~/perl5/perlbrew> will contain all install perl
executables, libraries, documentations, lib, site_libs. If you need to
install C<perlbrew>, and the perls it brews, into somewhere else
because, say, your HOME has limited quota, you can do that by setting
a C<PERLBREW_ROOT> environment variable before you run C<./perlbrew install>.

    export PERLBREW_ROOT=/mnt/perlbrew
    ./perlbrew install

The downloaded perlbrew is a self-contained standalone program that
embed all non-core modules it uses. It should be runnable with perl
5.8 or later versions of perl.

You may also install perlbrew from CPAN with cpan / cpanp / cpanm:

    cpan App::perlbrew

This installs 'perlbrew' into your current PATH and it is always
executed with your current perl.

NOTICE. When you install or upgrade perlbrew with cpan / cpanp /
cpanm, make sure you are not using one of the perls brewed with
perlbrew. If so, the `perlbrew` executable you just installed will not
be available after you swith to other perls. You might not be able to
invoke further C<perlbrew> commands after so because the executable
C<perlbrew> is not in your C<PATH> anymore. Installing it again with
cpan can temporarily solve this problem. To ensure you are not using
a perlbrewed perl, run C<perlbrew off> before upgrading.


It should be relatively safe to install C<App::perlbrew> with system
cpan (like C</usr/bin/cpan>) because then it will be installed under a
system PATH like C</usr/bin>, which is not effected by C<perlbrew switch>
command.

Again, it is recommended to let C<perlbrew> install itself. It's
easier, and it works better.

=head1 USAGE

Please read the program usage by running

    perlbrew

(No arguments.) To read a more detail one:

    perlbrew -h

Alternatively, this should also do:

    perldoc perlbrew

If you messed up too much or get confused by having to many perls
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

Patches and code improvements has been contributed by:

Tatsuhiko Miyagawa, Chris Prather, Yanick Champoux, aero, Jason May,
Jesse Leuhrs, Andrew Rodland, Justin Davis, Masayoshi Sekimura,
castaway, jrockway, chromatic, Goro Fuji, Sawyer X, and Danijel Tasov.

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
