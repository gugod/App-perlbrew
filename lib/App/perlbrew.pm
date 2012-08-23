package App::perlbrew;
use strict;
use warnings;
use 5.008;
our $VERSION = "0.47";

use Config;
use Capture::Tiny;
use Getopt::Long ();
use File::Spec::Functions qw( catfile catdir );
use File::Basename;
use File::Path::Tiny;
use FindBin;
use CPAN::Perl::Releases;

our $CONFIG;
our $PERLBREW_ROOT = $ENV{PERLBREW_ROOT} || catdir($ENV{HOME}, "perl5", "perlbrew");
our $PERLBREW_HOME = $ENV{PERLBREW_HOME} || catdir($ENV{HOME}, ".perlbrew");

local $SIG{__DIE__} = sub {
    my $message = shift;
    warn $message;
    exit 1;
};

sub root {
    my ($self, $new_root) = @_;

    if (defined($new_root)) {
        $self->{root} = $new_root;
    }

    return $self->{root} || $PERLBREW_ROOT;
}

sub current_perl {
    my ($self, $v) = @_;

    if ($v) {
        $self->{current_perl} = $v;
    }

    return $self->{current_perl} || $self->env('PERLBREW_PERL')  || ''
}

sub mkpath {
    File::Path::Tiny::mk(@_);
}

sub rmpath {
    File::Path::Tiny::rm(@_)
}

sub uniq(@) {
    my %a;
    grep { ++$a{$_} == 1 } @_;
}

sub min(@) {
    my @a = @_;
    my $m = $a[0];
    for my $x (@a) {
        $m = $x if $x < $m
    }
    return $m;
}

{
    my @command;
    sub http_get {
        my ($url, $header, $cb) = @_;

        if (ref($header) eq 'CODE') {
            $cb = $header;
            $header = undef;
        }

        if (! @command) {
            my @commands = (
                # curl's --fail option makes the exit code meaningful
                [qw( curl --silent --location --fail --insecure )],
                [qw( fetch -o - )],
                [qw( wget --no-check-certificate --quiet -O - )],
            );
            for my $command (@commands) {
                my $program = $command->[0];
                my $code = system("$program --version >/dev/null 2>&1") >> 8;
                if ($code != 127) {
                    @command = @$command;
                    last;
                }
            }
            die "You have to install either curl or wget\n"
                unless @command;
        }

        open my $fh, '-|', @command, $url
            or die "open() for '@command $url': $!";

        local $/;
        my $body = <$fh>;
        close $fh;
        die 'Page not retrieved; HTTP error code 400 or above.'
            if $command[0] eq 'curl' # Exit code is 22 on 404s etc
            and $? >> 8 == 22; # exit code is packed into $?; see perlvar
        die 'Page not retrieved: fetch failed.'
            if $command[0] eq 'fetch' # Exit code is not 0 on error
            and $?;
        die 'Server issued an error response.'
            if $command[0] eq 'wget' # Exit code is 8 on 404s etc
            and $? >> 8 == 8;

        return $cb ? $cb->($body) : $body;
    }
}

sub perl_version_to_integer {
    my $version = shift;
    my @v = split(/[\.\-_]/, $version);
    if ($v[1] <= 5) {
        $v[2] ||= 9;
        $v[3] = 0;
    }
    else {
        $v[3] ||= 9;
        $v[3] =~ s/[^0-9]//g;
    }

    return $v[0]*10000000 + $v[1]*10000 + $v[2]*10 + $v[3];
}

sub new {
    my($class, @argv) = @_;

    my %opt = (
        original_argv  => \@argv,
        force => 0,
        quiet => 0,
        D => [],
        U => [],
        A => [],
        sitecustomize => '',
    );

    # build a local @ARGV to allow us to use an older
    # Getopt::Long API in case we are building on an older system
    local (@ARGV) = @argv;

    Getopt::Long::Configure(
        'pass_through',
        'no_ignore_case',
        'bundling',
    );

    Getopt::Long::GetOptions(
        \%opt,

        'force|f!',
        'notest|n!',
        'quiet|q!',
        'verbose|v',
        'as=s',
        'help|h',
        'version',
        'root=s',

        # options passed directly to Configure
        'D=s@',
        'U=s@',
        'A=s@',

        'j=i',
        # options that affect Configure and customize post-build
        'sitecustomize=s',
    )
      or run_command_help(1);

    $opt{args} = \@ARGV;

    # fix up the effect of 'bundling'
    foreach my $flags (@opt{qw(D U A)}) {
        foreach my $value(@{$flags}) {
            $value =~ s/^=//;
        }
    }

    return bless \%opt, $class;
}

sub env {
    my ($self, $name) = @_;
    return $ENV{$name} if $name;
    return \%ENV;
}

sub path_with_tilde {
    my ($self, $dir) = @_;
    my $home = $self->env('HOME');
    $dir =~ s/^$home/~/ if $home;
    return $dir;
}

sub is_shell_csh {
    my ($self) = @_;
    return 1 if $self->env('SHELL') =~ /(t?csh)/;
    return 0;
}

sub run {
    my($self) = @_;
    $self->run_command($self->args);
}

sub args {
    my ( $self ) = @_;
    return @{ $self->{args} };
}

sub commands {
    my ( $self ) = @_;

    my $package =  ref $self ? ref $self : $self;

    my @commands;
    my $symtable = do {
        no strict 'refs';
        \%{$package . '::'};
    };

    foreach my $sym (keys %$symtable) {
        if($sym =~ /^run_command_/) {
            my $glob = $symtable->{$sym};
            if(defined *$glob{CODE}) {
                $sym =~ s/^run_command_//;
                $sym =~ s/_/-/g;
                push @commands, $sym;
            }
        }
    }

    return @commands;
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

sub find_similar_commands {
    my ( $self, $command ) = @_;
    my $SIMILAR_DISTANCE = 6;

    my @commands = sort {
        $a->[1] <=> $b->[1]
    } grep {
        defined
    } map {
        my $d = editdist($_, $command);

        ($d < $SIMILAR_DISTANCE) ? [ $_, $d ] : undef
    } $self->commands;

    if(@commands) {
        my $best  = $commands[0][1];
        @commands = map { $_->[0] } grep { $_->[1] == $best } @commands;
    }

    return @commands;
}

sub download {
    my ($self, $url, $path, $on_error) = @_;

    my $mirror = $self->config->{mirror};
    my $header = $mirror ? { 'Cookie' => "cpan=$mirror->{url}" } : undef;

    open my $BALL, ">", $path or die "Failed to open $path for writing.\n";

    http_get(
        $url,
        $header,
        sub {
            my ($body) = @_;

            unless ($body) {
                if (ref($on_error) eq 'CODE') {
                    $on_error->($url);
                }
                else {
                    die "ERROR: Failed to download $url.\n"
                }
            }


            print $BALL $body;
        }
    );

    close $BALL;
}

sub run_command {
    my ( $self, $x, @args ) = @_;
    my $command = $x;

    $self->{log_file} ||= catfile($self->root, "build.log");
    if($self->{version}) {
        $x = 'version';
    }
    elsif(!$x) {
        $x = 'help';
        @args = (0, $self->{help} ? 2 : 0);
    }
    elsif($x eq 'help') {
        @args = (0, 2) unless @args;
    }

    my $s = $self->can("run_command_$x");
    unless ($s) {
        $x =~ y/-/_/;
        $s = $self->can("run_command_$x");
    }

    unless($s) {
        my @commands = $self->find_similar_commands($x);

        if(@commands > 1) {
            @commands = map { '    ' . $_ } @commands;
            die "Unknown command: `$command`. Did you mean one of the following?\n" . join("\n", @commands) . "\n";
        } elsif(@commands == 1) {
            die "Unknown command: `$command`. Did you mean `$commands[0]`?\n";
        } else {
            die "Unknown command: `$command`. Typo?\n";
        }
    }

    if ($x eq 'install') {
        # prepend "perl-" to version number, but only if there is an argument
        $args[0] =~ s/\A((?:\d+\.)*\d+)\Z/perl-$1/
            if @args;
    }

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
    my ($self, $status, $verbose) = @_;

    require Pod::Usage;

    if ($status && !defined($verbose)) {
        if ($self->can("run_command_help_${status}")) {
            $self->can("run_command_help_${status}")->($self);
        }
        else {
            my $out = "";
            open my $fh, ">", \$out;

            Pod::Usage::pod2usage(
                -exitval   => "NOEXIT",
                -verbose   => 99,
                -sections  => "COMMAND: " . uc($status),
                -output    => $fh,
                -noperldoc => 1
            );
            $out =~ s/\A[^\n]+\n//s;
            $out =~ s/^    //gm;

            if ($out =~ /\A\s*\Z/) {
                $out = "Cannot find documentation for '$status'\n\n";
            }

            print "\n$out";
            close $fh;
        }
    }
    else {
        Pod::Usage::pod2usage(
            -noperldoc => 1,
            -verbose => $verbose||0,
            -exitval => (defined $status ? $status : 1)
        );
    }
}

# introspection for compgen
my %comp_installed = (
    use    => 1,
    switch => 1,
);

sub run_command_compgen {
    my($self, $cur, @args) = @_;

    $cur = 0 unless defined($cur);

    # do `tail -f bashcomp.log` for debugging
    if($self->env('PERLBREW_DEBUG_COMPLETION')) {
        open my $log, '>>', 'bashcomp.log';
        print $log "[$$] $cur of [@args]\n";
    }
    my $subcommand           = $args[1];
    my $subcommand_completed = ( $cur >= 2 );

    if(!$subcommand_completed) {
        $self->_compgen($subcommand, $self->commands);
    }
    else { # complete args of a subcommand
        if($comp_installed{$subcommand}) {
            if($cur <= 2) {
                my $part;
                if(defined($part = $args[2])) {
                    $part = qr/ \Q$part\E /xms;
                }
                $self->_compgen($part,
                    map{ $_->{name} } $self->installed_perls());
            }
        }
        elsif($subcommand eq 'help') {
            if($cur <= 2) {
                $self->_compgen($args[2], $self->commands());
            }
        }
        else {
            # TODO
        }
    }
}

sub _compgen {
    my($self, $part, @reply) = @_;
    if(defined $part) {
        $part = qr/\A \Q$part\E /xms if ref($part) ne ref(qr//);
        @reply = grep { /$part/ } @reply;
    }
    foreach my $word(@reply) {
        print $word, "\n";
    }
}

sub run_command_available {
    my ( $self, $dist, $opts ) = @_;

    my @available = $self->available_perls(@_);
    my @installed = $self->installed_perls(@_);

    my $is_installed;
    for my $available (@available) {
        $is_installed = 0;
        for my $installed (@installed) {
            my $name = $installed->{name};
            my $cur  = $installed->{is_current};
            if ( $available eq $installed->{name} ) {
                $is_installed = 1;
                last;
            }
        }
        print $is_installed ? 'i ' : '  ', $available, "\n";
    }
}

sub available_perls {
    my ( $self, $dist, $opts ) = @_;

    my $url = "http://www.cpan.org/src/README.html";
    my $html = http_get( $url, undef, undef );

    unless($html) {
        die "\nERROR: Unable to retrieve the list of perls.\n\n";
    }

    my @available_versions;

    for ( split "\n", $html ) {
        push @available_versions, $1
          if m|<td><a href="http://www.cpan.org/src/.+?">(.+?)</a></td>|;
    }
    s/\.tar\.gz// for @available_versions;

    return @available_versions;
}

sub perl_release {
    my ($self, $version) = @_;

    my $tarballs = CPAN::Perl::Releases::perl_tarballs($version);

    my $x = (values %$tarballs)[0];

    if ($x) {
        my $dist_tarball = (split("/", $x))[-1];
        my $dist_tarball_url = "http://search.cpan.org/CPAN/authors/id/$x";
        return ($dist_tarball, $dist_tarball_url);
    }

    my $mirror = $self->config->{mirror};
    my $header = $mirror ? { 'Cookie' => "cpan=$mirror->{url}" } : undef;
    my $html = http_get("http://search.cpan.org/dist/perl-${version}", $header);

    unless ($html) {
        die "ERROR: Failed to download perl-${version} tarball.";
    }

    my ($dist_path, $dist_tarball) =
        $html =~ m[<a href="(/CPAN/authors/id/.+/(perl-${version}.tar.(gz|bz2)))">Download</a>];
    die "ERROR: Cannot find the tarball for perl-$version\n"
        if !$dist_path and !$dist_tarball;
    my $dist_tarball_url = "http://search.cpan.org${dist_path}";
    return ($dist_tarball, $dist_tarball_url);
}

sub run_command_init {
    my $self = shift;
    my $HOME = $self->env('HOME');

    mkpath($_) for (map { catdir($self->root, $_) } qw(perls dists build etc bin));

    open BASHRC, ">", catfile($self->root, "etc", "bashrc");
    print BASHRC BASHRC_CONTENT();
    close BASHRC;

    open BASH_COMPLETION, ">", catfile($self->root, "etc", "perlbrew-completion.bash");
    print BASH_COMPLETION BASH_COMPLETION_CONTENT();
    close BASH_COMPLETION;

    open CSH_WRAPPER, ">", catfile($self->root, "etc", "csh_wrapper");
    print CSH_WRAPPER CSH_WRAPPER_CONTENT();
    close CSH_WRAPPER;

    open CSH_REINIT, ">", catfile($self->root, "etc", "csh_reinit");
    print CSH_REINIT CSH_REINIT_CONTENT();
    close CSH_REINIT;

    open CSH_SET_PATH, ">", catfile($self->root, "etc", "csh_set_path");
    print CSH_SET_PATH CSH_SET_PATH_CONTENT();
    close CSH_SET_PATH;

    open CSHRC, ">", catfile($self->root, "etc", "cshrc");
    print CSHRC CSHRC_CONTENT();
    close CSHRC;

    my ( $shrc, $yourshrc );
    if ( $self->is_shell_csh) {
        $shrc     = 'cshrc';
        $self->env("SHELL") =~ m/(t?csh)/;
        $yourshrc = $1 . "rc";
    }
    elsif ($self->env("SHELL") =~ m/zsh$/) {
        $shrc = "bashrc";
        $yourshrc = 'zshenv';
    }
    else {
        $shrc = "bashrc";
        $yourshrc = "bash_profile";
    }

    my $root_dir = $self->path_with_tilde($self->root);
    my $pb_home_dir = $self->path_with_tilde($PERLBREW_HOME);

    my $code = qq(    source $root_dir/etc/${shrc});
    if ($PERLBREW_HOME ne catdir($ENV{HOME}, ".perlbrew")) {
        $code = "    export PERLBREW_HOME=$pb_home_dir\n" . $code;
    }

    print <<INSTRUCTION;
Perlbrew environment initiated under $root_dir

Append the following piece of code to the end of your ~/.${yourshrc} and start a
new shell, perlbrew should be up and fully functional from there:

$code

For further instructions, simply run `perlbrew` to see the help message.

Happy brewing!

INSTRUCTION

}

sub run_command_self_install {
    my $self = shift;

    my $executable = $0;

    unless (File::Spec->file_name_is_absolute($executable)) {
        $executable = File::Spec->rel2abs($executable);
    }

    my $target = catfile($self->root, "bin", "perlbrew");
    if ($executable eq $target) {
        print "You are already running the installed perlbrew:\n\n    $executable\n";
        exit;
    }

    mkpath( catdir($self->root, "bin" ));

    open my $fh, "<", $executable;
    my @lines =  <$fh>;
    close $fh;

    $lines[0] = $self->system_perl_shebang . "\n";

    open $fh, ">", $target;
    print $fh $_ for @lines;
    close $fh;

    chmod(0755, $target);

    my $path = $self->path_with_tilde($target);

    print <<HELP;
The perlbrew is installed as:

    $path

You may trash the downloaded $executable from now on.

HELP

    $self->run_command_init();
    return;
}

sub do_install_git {
    my $self = shift;
    my $dist = shift;

    my $dist_name;
    my $dist_git_describe;
    my $dist_version;
    require Cwd;
    my $cwd = Cwd::cwd();
    chdir $dist;
    if (`git describe` =~ /v((5\.\d+\.\d+(?:-RC\d)?)(-\d+-\w+)?)$/) {
        $dist_name = 'perl';
        $dist_git_describe = "v$1";
        $dist_version = $2;
    }
    chdir $cwd;
    my $dist_extracted_dir = File::Spec->rel2abs( $dist );
    $self->do_install_this($dist_extracted_dir, $dist_version, "$dist_name-$dist_version");
    return;
}

sub do_install_url {
    my $self = shift;
    my $dist = shift;

    my $dist_name = 'perl';
    # need the period to account for the file extension
    my ($dist_version) = $dist =~ m/-([\d.]+(?:-RC\d+)?|git)\./;
    my ($dist_tarball) = $dist =~ m{/([^/]*)$};

    my $dist_tarball_path = catfile($self->root, "dists", $dist_tarball);
    my $dist_tarball_url  = $dist;
    $dist = "$dist_name-$dist_version"; # we install it as this name later

    if ($dist_tarball_url =~ m/^file/) {
        print "Installing $dist from local archive $dist_tarball_url\n";
        $dist_tarball_url =~ s/^file:\/+/\//;
        $dist_tarball_path = $dist_tarball_url;
    }
    else {
        print "Fetching $dist as $dist_tarball_path\n";
        $self->download($dist_tarball_url, $dist_tarball_path);
    }

    my $dist_extracted_path = $self->do_extract_tarball($dist_tarball_path);
    $self->do_install_this($dist_extracted_path, $dist_version, $dist);
    return;
}

sub do_extract_tarball {
    my $self = shift;
    my $dist_tarball = shift;

    # Was broken on Solaris, where GNU tar is probably
    # installed as 'gtar' - RT #61042
    my $tarx =
        ($^O eq 'solaris' ? 'gtar ' : 'tar ') .
        ( $dist_tarball =~ m/bz2$/ ? 'xjf' : 'xzf' );
    my $extract_command = "cd @{[ $self->root ]}/build; $tarx $dist_tarball";
    die "Failed to extract $dist_tarball" if system($extract_command);
    $dist_tarball =~ s{.*/([^/]+)\.tar\.(?:gz|bz2)$}{$1};
    return "@{[ $self->root ]}/build/$dist_tarball"; # Note that this is incorrect for blead
}

sub do_install_blead {
    my $self = shift;
    my $dist = shift;

    my $dist_name           = 'perl';
    my $dist_git_describe   = 'blead';
    my $dist_version        = 'blead';

    # We always blindly overwrite anything that's already there,
    # because blead is a moving target.
    my $dist_tarball = 'blead.tar.gz';
    my $dist_tarball_path = catfile($self->root, "dists", $dist_tarball);
    print "Fetching $dist_git_describe as $dist_tarball_path\n";

    $self->download(
        "http://perl5.git.perl.org/perl.git/snapshot/$dist_tarball", $dist_tarball_path,
        sub {
            die "\nERROR: Failed to download perl-blead tarball.\n\n";
        }
    );


    # Returns the wrong extracted dir for blead
    $self->do_extract_tarball($dist_tarball_path);

    my $build_dir = catdir($self->root, "build");
    local *DIRH;
    opendir DIRH, $build_dir or die "Couldn't open ${build_dir}: $!";
    my @contents = readdir DIRH;
    closedir DIRH or warn "Couldn't close ${build_dir}: $!";
    my @candidates = grep { m/^perl-[0-9a-f]{7,8}$/ } @contents;
    # Use a Schwartzian Transform in case there are lots of dirs that
    # look like "perl-$SHA1", which is what's inside blead.tar.gz,
    # so we stat each one only once.
    @candidates =   map  { $_->[0] }
                    sort { $b->[1] <=> $a->[1] } # descending
                    map  { [ $_, (stat( catdir($build_dir, $_) ))[9] ] } @candidates;
    my $dist_extracted_dir = catdir($self->root, "build", $candidates[0]); # take the newest one
    $self->do_install_this($dist_extracted_dir, $dist_version, "$dist_name-$dist_version");
    return;
}

sub do_install_release {
    my $self = shift;
    my $dist = shift;

    my ($dist_name, $dist_version) = $dist =~ m/^(.*)-([\d.]+(?:-RC\d+)?)$/;

    my ($dist_tarball, $dist_tarball_url) = $self->perl_release($dist_version);
    my $dist_tarball_path = catfile($self->root, "dists", $dist_tarball);

    if (-f $dist_tarball_path) {
        print "Use the previously fetched ${dist_tarball}\n"
            if $self->{verbose};
    }
    else {
        print "Fetching $dist as $dist_tarball_path\n" unless $self->{quiet};
        $self->download( $dist_tarball_url, $dist_tarball_path );
    }

    my $dist_extracted_path = $self->do_extract_tarball($dist_tarball_path);
    $self->do_install_this($dist_extracted_path,$dist_version, $dist);
    return;
}

sub run_command_install {
    my ( $self, $dist, $opts ) = @_;
    $self->{dist_name} = $dist;

    unless ($dist) {
        ## Show a deprecation warning.
        print STDERR "-" x 76 . "\n";
        print STDERR "DEPRECATION WARNING:\n\n  Run `perlbrew install` to install perlbrew itself is deprecated. \n  Please run `perlbrew self-install` in the future instead.\n\n";
        print STDERR "-" x 76 . "\n\n";
        sleep 5;

        $self->run_command_self_install();
        return
    }

    my $installation_name = $self->{as} || $dist;
    if ($self->is_installed( $installation_name ) && !$self->{force}) {
        die "\nABORT: $installation_name is already installed.\n\n";
    }

    my $help_message = "Unknown installation target \"$dist\", abort.\nPlease see `perlbrew help` for the instruction on using the install command.\n\n";

    my ($dist_name, $dist_version) = $dist =~ m/^(.*)-([\d.]+(?:-RC\d+)?|git)$/;
    if (!$dist_name || !$dist_version) { # some kind of special install
        if (-d "$dist/.git") {
            $self->do_install_git($dist);
        }
        if (-f $dist) {
            $self->do_install_archive($dist);
        }
        elsif ($dist =~ m/^(?:https?|ftp|file)/) { # more protocols needed?
            $self->do_install_url($dist);
        }
        elsif ($dist =~ m/(?:perl-)?blead$/) {
            $self->do_install_blead($dist);
        }
        else {
            die $help_message;
        }
    }
    elsif ($dist_name eq 'perl') {
        $self->do_install_release($dist);
    }
    else {
        die $help_message;
    }

    return;
}

sub run_command_download {
    my ($self, $dist) = @_;

    my ($dist_name, $dist_version) = $dist =~ m/^(.*)-([\d.]+(?:-RC\d+)?)$/;

    my ($dist_tarball, $dist_tarball_url) = $self->perl_release($dist_version);
    my $dist_tarball_path = catfile($self->root, "dists", $dist_tarball);

    if (-f $dist_tarball_path && !$self->{force}) {
        print "$dist_tarball already exists\n";
    }
    else {
        print "Fetching $dist as $dist_tarball_path\n" unless $self->{quiet};
        $self->download( $dist_tarball_url, $dist_tarball_path );
    }
}

sub system_perl_path {
    my ($self) = @_;
    my $path = $self->env("PATH") or return;
    my $perlbrew_root = $self->root;
    my $perlbrew_home = $PERLBREW_HOME;

    my @path_without_perlbrew = grep {
        index($_, $perlbrew_home) < 0
    } grep {
        index($_, $perlbrew_root) < 0
    } split /:/, $path;

    my $system_perl_path = do {
        local $ENV{PATH} = join(":", @path_without_perlbrew);
        `perl -MConfig -e 'print \$Config{perlpath}'`
    };

    return $system_perl_path;
}

sub system_perl_shebang {
    my ($self) = @_;
    return $Config{sharpbang}. $self->system_perl_path;
}

sub run_command_display_system_perl_shebang {
    my ($self) = @_;
    print $self->system_perl_shebang . "\n";
}

sub run_command_display_original_path {
    my ($self) = @_;
    my $path = join ":" =>  grep { index($_, $self->env("PERLBREW_ROOT") ) < 0 } split /:/, $self->env("PATH");
    print $path . "\n";
}

sub do_install_archive {
    my $self = shift;
    my $dist_tarball_path = shift;
    my $dist_version;
    my $installation_name;

    if (basename($dist_tarball_path) =~ m{perl-?(5.+)\.tar\.(gz|bz2)\Z}) {
        $dist_version = $1;
        $installation_name = "perl-${dist_version}";
    }

    unless ($dist_version && $installation_name) {
        die "Unable to determine perl version from archive filename.\n\nThe archive name should look like perl-5.x.y.tar.gz or perl-5.x.y.tar.bz2\n";
    }

    my $dist_extracted_path = $self->do_extract_tarball($dist_tarball_path);
    $self->do_install_this($dist_extracted_path, $dist_version, $installation_name);
    return;
}

sub do_install_this {
    my ($self, $dist_extracted_dir, $dist_version, $as) = @_;

    my @d_options = @{ $self->{D} };
    my @u_options = @{ $self->{U} };
    my @a_options = @{ $self->{A} };
    my $sitecustomize = $self->{sitecustomize};
    $as = $self->{as} if $self->{as};

    if ( $sitecustomize ) {
        die "Could not read sitecustomize file '$sitecustomize'\n"
            unless -r $sitecustomize;
        push @d_options, "usesitecustomize";
    }

    my $perlpath = $self->root . "/perls/$as";
    my $patchperl = $self->root . "/bin/patchperl";

    unless (-x $patchperl && -f _) {
        $patchperl = "patchperl";
    }

    unshift @d_options, qq(prefix=$perlpath);
    push @d_options, "usedevel" if $dist_version =~ /5\.1[13579]|git|blead/;

    unless (grep { /eval:scripdir=/} @a_options) {
        push @a_options, "'eval:scriptdir=${perlpath}/bin'";
    }

    print "Installing $dist_extracted_dir into " . $self->path_with_tilde("@{[ $self->root ]}/perls/$as") . "\n";
    print <<INSTALL if !$self->{verbose};

This could take a while. You can run the following command on another shell to track the status:

  tail -f @{[ $self->path_with_tilde($self->{log_file}) ]}

INSTALL

    my @preconfigure_commands = (
        "cd $dist_extracted_dir",
        "rm -f config.sh Policy.sh",
        $patchperl,
    );

    my $configure_flags = $self->env("PERLBREW_CONFIGURE_FLAGS");
    unless (defined($configure_flags)) {
        if ( perl_version_to_integer($dist_version) >= perl_version_to_integer("5.8.9") ) {
            $configure_flags = '-de -Duserelocableinc';
        }
        else {
            $configure_flags = '-de';
        }
    }

    my @configure_commands = (
        "sh Configure $configure_flags " .
            join( ' ',
                ( map { qq{'-D$_'} } @d_options ),
                ( map { qq{'-U$_'} } @u_options ),
                ( map { qq{'-A$_'} } @a_options ),
            ),
        $dist_version =~ /^5\.(\d+)\.(\d+)/
            && ($1 < 8 || $1 == 8 && $2 < 9)
                ? ("$^X -i -nle 'print unless /command-line/' makefile x2p/makefile")
                : ()
    );

    my @build_commands = (
        "make " . ($self->{j} ? "-j$self->{j}" : "")
    );

    # Test via "make test_harness" if available so we'll get
    # automatic parallel testing via $HARNESS_OPTIONS. The
    # "test_harness" target was added in 5.7.3, which was the last
    # development release before 5.8.0.
    my $test_target = "test";
    if ($dist_version =~ /^5\.(\d+)\.(\d+)/
        && ($1 >= 8 || $1 == 7 && $2 == 3)) {
        $test_target = "test_harness";
    }
    local $ENV{TEST_JOBS}=$self->{j}
      if $test_target eq "test_harness" && ($self->{j}||1) > 1;

    my @install_commands = $self->{notest} ? "make install" : ("make $test_target", "make install");
    @install_commands    = join " && ", @install_commands unless($self->{force});

    my $cmd = join " && ",
    (
        @preconfigure_commands,
        @configure_commands,
        @build_commands,
        @install_commands
    );

    unlink($self->{log_file});

    if($self->{verbose}) {
        $cmd = "($cmd) 2>&1 | tee $self->{log_file}";
        print "$cmd\n" if $self->{verbose};
    } else {
        $cmd = "($cmd) >> '$self->{log_file}' 2>&1 ";
    }


    delete $ENV{$_} for qw(PERL5LIB PERL5OPT);

    if ($self->do_system($cmd)) {
        my $newperl = catfile($self->root, "perls", $as, "bin", "perl");
        unless (-e $newperl) {
            $self->run_command_symlink_executables($as);
        }
        if ( $sitecustomize ) {
            my $capture = $self->do_capture("$newperl -V:sitelib");
            my ($sitelib) = $capture =~ /sitelib='(.*)';/;
            mkpath($sitelib) unless -d $sitelib;
            my $target = "$sitelib/sitecustomize.pl";
            open my $dst, ">", $target
                or die "Could not open '$target' for writing: $!\n";
            open my $src, "<", $sitecustomize
                or die "Could not open '$sitecustomize' for reading: $!\n";
            print {$dst} do { local $/; <$src> };
        }
        print <<SUCCESS;
Installed $dist_extracted_dir as $as successfully. Run the following command to switch to it.

  perlbrew switch $as

SUCCESS
    }
    else {
        die <<FAIL;
Installing $dist_extracted_dir failed. See $self->{log_file} to see why.
You might want to try upgrading patchperl before trying again:

  perlbrew install-patchperl

If you want to force install the distribution, try:

  perlbrew --force install $self->{dist_name}

FAIL


    }
    return;
}

sub do_install_program_from_url {
    my ($self, $url, $program_name, $body_filter) = @_;

    my $out = $self->root . "/bin/" . $program_name;

    if (-f $out && !$self->{force}) {
        require ExtUtils::MakeMaker;

        my $ans = ExtUtils::MakeMaker::prompt("\n$out already exists, are you sure to override ? [y/N]", "N");

        if ($ans !~ /^Y/i) {
            print "\n$program_name installation skipped.\n\n" unless $self->{quiet};
            return;
        }
    }

    my $body = http_get($url) or die "\nERROR: Failed to retrieve $program_name executable.\n\n";

    if ($body_filter && ref($body_filter) eq "CODE") {
        $body = $body_filter->($body);
    }

    mkpath("@{[ $self->root ]}/bin") unless -d "@{[ $self->root ]}/bin";
    open my $OUT, '>', $out or die "cannot open file($out): $!";
    print $OUT $body;
    close $OUT;
    chmod 0755, $out;
    print "\n$program_name is installed to\n\n    $out\n\n" unless $self->{quiet};
}

sub do_system {
  my ($self, @cmd) = @_;
  return ! system(@cmd);
}

sub do_capture {
  my ($self, $cmd) = @_;
  return Capture::Tiny::capture {
    $self->do_system($cmd);
  };
}

sub format_perl_version {
    my $self    = shift;
    my $version = shift;
    return sprintf "%d.%d.%d",
      substr( $version, 0, 1 ),
      substr( $version, 2, 3 ),
      substr( $version, 5 );

}

sub installed_perls {
    my $self    = shift;

    my @result;
    my $root = $self->root;

    for (<$root/perls/*>) {
        my ($name) = $_ =~ m/\/([^\/]+$)/;
        my $executable = catfile($_, 'bin', 'perl');

        push @result, {
            name        => $name,
            version     => $self->format_perl_version(`$executable -e 'print \$]'`),
            is_current  => ($self->current_perl eq $name) && !$self->env("PERLBREW_LIB"),
            libs => [ $self->local_libs($name) ]
        };
    }

    return @result;
}

sub local_libs {
    my ($self, $perl_name) = @_;

    my @libs = map { substr($_, length($PERLBREW_HOME) + 6) } <$PERLBREW_HOME/libs/*>;

    if ($perl_name) {
        @libs = grep { /^$perl_name\@/ } @libs;
    }

    my $current = $self->current_perl . '@' . ($self->env("PERLBREW_LIB") || '');

    @libs = map {
        my ($p, $l) = split(/@/, $_);

        +{
            name       => $_,
            is_current => $_ eq $current,
            perl_name  => $p,
            lib_name   => $l
        }
    } @libs;
    return @libs;
}

sub is_installed {
    my ($self, $name) = @_;

    return grep { $name eq $_->{name} } $self->installed_perls;
}

# Return a hash of PERLBREW_* variables
sub perlbrew_env {
    my ($self, $name) = @_;

    my %env = (
        PERLBREW_VERSION => $VERSION,
        PERLBREW_PATH    => catdir($self->root, "bin"),
        PERLBREW_MANPATH => "",
        PERLBREW_ROOT => $self->root
    );

    if ($name) {
        my ($perl_name, $lib_name) = $self->resolve_installation_name($name);

        unless ($perl_name) {
            die "\nERROR: The installation \"$name\" is unknown.\n\n";
        }

        if(-d  "@{[ $self->root ]}/perls/$perl_name/bin") {
            $env{PERLBREW_PERL}    = $perl_name;
            $env{PERLBREW_PATH}   .= ":" . catdir($self->root, "perls", $perl_name, "bin");
            $env{PERLBREW_MANPATH} = catdir($self->root, "perls", $perl_name, "man")
        }

        if ($lib_name) {
            require local::lib;

            if (
                $ENV{PERL_LOCAL_LIB_ROOT}
                && $ENV{PERL_LOCAL_LIB_ROOT} =~ /^$PERLBREW_HOME/
            ) {
                my %deactivate_env = local::lib->build_deact_all_environment_vars_for($ENV{PERL_LOCAL_LIB_ROOT});
                @env{keys %deactivate_env} = values %deactivate_env;
            }

            my $base = "$PERLBREW_HOME/libs/${perl_name}\@${lib_name}";

            if (-d $base) {
                delete $ENV{PERL_LOCAL_LIB_ROOT};
                @ENV{keys %env} = values %env;
                my %lib_env = local::lib->build_environment_vars_for($base, 0, 1);

                $env{PERLBREW_PATH}    = catdir($base, "bin") . ":" . $env{PERLBREW_PATH};
                $env{PERLBREW_MANPATH} = catdir($base, "man") . ":" . $env{PERLBREW_MANPATH};
                $env{PERLBREW_LIB}  = $lib_name;

                $env{PERL_MM_OPT}   = $lib_env{PERL_MM_OPT};
                $env{PERL_MB_OPT}   = $lib_env{PERL_MB_OPT};
                $env{PERL5LIB}      = $lib_env{PERL5LIB};
                $env{PERL_LOCAL_LIB_ROOT} = $lib_env{PERL_LOCAL_LIB_ROOT};
            }
        }
        else {
            if ($self->env("PERLBREW_LIB")) {
                $env{PERLBREW_LIB}        = "";
                $env{PERL_MM_OPT}         = "";
                $env{PERL_MB_OPT}         = "";
                $env{PERL5LIB}            = "";
                $env{PERL_LOCAL_LIB_ROOT} = "";
            }
        }
    }
    else {
        $env{PERLBREW_PERL} = "";
        $env{PERLBREW_LIB}  = "";
        $env{PERL_MM_OPT}   = "";
        $env{PERL_MB_OPT}   = "";
        $env{PERL5LIB}      = "";
        $env{PERL_LOCAL_LIB_ROOT} = "";
    }

    return %env;
}

sub run_command_list {
    my $self = shift;

    for my $i ( $self->installed_perls ) {
        print $i->{is_current} ? '* ': '  ',
            $i->{name},
            (index($i->{name}, $i->{version}) < 0) ? " ($i->{version})" : "",
            "\n";

        for my $lib (@{$i->{libs}}) {
            print $lib->{is_current} ? "* " : "  ",
                $lib->{name}, "\n"
        }
    }
}


sub launch_sub_shell {
    my ($self, $name) = @_;
    my $shell = $self->env('SHELL');

    my $shell_opt = "";

    if ($shell =~ /\/zsh$/) {
        $shell_opt = "-d -f";

        if ($^O eq 'darwin') {
            my $root_dir = $self->root;
            print <<"WARNINGONMAC"
--------------------------------------------------------------------------------
WARNING: zsh perlbrew sub-shell is not working on Mac OSX Lion.

It is known that on MacOS Lion, zsh always resets the value of PATH on launching
a sub-shell. Effectively nullify the changes required by perlbrew sub-shell. You
may `echo \$PATH` to examine it and if you see perlbrew related paths are in the
end, instead of in the beginning, you are unfortunate.

You are advertised to include the following line to your ~/.zshenv as a better
way to work with perlbrew:

    source $root_dir/etc/bashrc

--------------------------------------------------------------------------------
WARNINGONMAC


        }
    }
    elsif  ($shell =~ /\/bash$/)  {
        $shell_opt = "--noprofile --norc";
    }

    my %env = ($self->perlbrew_env($name), PERLBREW_SKIP_INIT => 1);

    unless ($ENV{PERLBREW_VERSION}) {
        my $root = $self->root;
        # The user does not source bashrc/csh in their shell initialization.
        $env{PATH}    = $env{PERLBREW_PATH}    . ":" . join ":", grep { !/$root/ } split ":", $ENV{PATH};
        $env{MANPATH} = $env{PERLBREW_MANPATH} . ":" . join ":", grep { !/$root/ } split ":", $ENV{MANPATH};
    }

    my $command = "env ";
    while (my ($k, $v) = each(%env)) {
        $command .= "$k=\"$v\" ";
    }
    $command .= " $shell $shell_opt";

    print "\nA sub-shell is launched with $name as the activated perl. Run 'exit' to finish it.\n\n";
    exec($command);
}

sub run_command_use {
    my $self = shift;
    my $perl = shift;

    if ( !$perl ) {
        my $current = $self->current_perl;
        if ($current) {
            print "Currently using $current\n";
        } else {
            print "No version in use; defaulting to system\n";
        }
        return;
    }

    $self->launch_sub_shell($perl);

}

sub run_command_switch {
    my ( $self, $dist, $alias ) = @_;

    unless ( $dist ) {
        my $current = $self->current_perl;
        printf "Currently switched %s\n",
            ( $current ? "to $current" : 'off' );
        return;
    }

    die "Cannot use for alias something that starts with 'perl-'\n"
      if $alias && $alias =~ /^perl-/;

    die "${dist} is not installed\n" unless -d catdir($self->root, "perls", $dist);

    if ($self->env("PERLBREW_BASHRC_VERSION")) {
        local $ENV{PERLBREW_PERL} = $dist;
        my $HOME = $self->env('HOME');
        my $pb_home = $self->env("PERLBREW_HOME") || $PERLBREW_HOME;

        mkpath($pb_home);
        system("$0 env $dist > " . catfile($pb_home, "init"));

        print "Switched to $dist.\n\n";
    }
    else {
        $self->launch_sub_shell($dist);
    }
}

sub run_command_off {
    my $self = shift;
    $self->launch_sub_shell;
}

sub run_command_switch_off {
    my $self = shift;
    my $pb_home = $self->env("PERLBREW_HOME") || $PERLBREW_HOME;

    mkpath($pb_home);
    system("env PERLBREW_PERL= $0 env > " . catfile($pb_home, "init"));

    print "\nperlbrew is switched off. Please exit this shell and start a new one to make it effective.\n";
    print "To immediately make it effective, run this line in this terminal:\n\n    exec @{[ $self->env('SHELL') ]}\n\n";
}

sub run_command_mirror {
    my($self) = @_;
    print "Fetching mirror list\n";
    my $raw = http_get("http://search.cpan.org/mirror");

    unless ($raw) {
        die "\nERROR: Failed to retrieve the mirror list.\n\n";
    }

    my $found;
    my @mirrors;
    foreach my $line ( split m{\n}, $raw ) {
        $found = 1 if $line =~ m{<select name="mirror">};
        next if ! $found;
        last if $line =~ m{</select>};
        if ( $line =~ m{<option value="(.+?)">(.+?)</option>} ) {
            my $url  = $1;
            my $name = $2;
            $name =~ s/&#(\d+);/chr $1/seg;
            $url =~ s/&#(\d+);/chr $1/seg;
            push @mirrors, { url => $url, name => $name };
        }
    }

    require ExtUtils::MakeMaker;
    my $select;
    my $max = @mirrors;
    my $id  = 0;
    while ( @mirrors ) {
        my @page = splice(@mirrors,0,20);
        my $base = $id;
        printf "[% 3d] %s\n", ++$id, $_->{name} for @page;
        my $remaining = $max - $id;
        my $ask = "Select a mirror by number or press enter to see the rest "
                . "($remaining more) [q to quit, m for manual entry]";
        my $val = ExtUtils::MakeMaker::prompt( $ask );
        if ( ! length $val )  { next }
        elsif ( $val eq 'q' ) { last }
        elsif ( $val eq 'm' ) {
            my $url  = ExtUtils::MakeMaker::prompt("Enter the URL of your CPAN mirror:");
            my $name = ExtUtils::MakeMaker::prompt("Enter a Name: [default: My CPAN Mirror]") || "My CPAN Mirror";
            $select = { name => $name, url => $url };
            last;
        }
        elsif ( not $val =~ /\s*(\d+)\s*/ ) {
            die "Invalid answer: must be 'q', 'm' or a number\n";
        }
        elsif (1 <= $val and $val <= $max) {
            $select = $page[ $val - 1 - $base ];
            last;
        }
        else {
            die "Invalid ID: must be between 1 and $max\n";
        }
    }
    die "You didn't select a mirror!\n" if ! $select;
    print "Selected $select->{name} ($select->{url}) as the mirror\n";
    my $conf = $self->config;
    $conf->{mirror} = $select;
    $self->_save_config;
    return;
}

sub run_command_env {
    my($self, $perl) = @_;

    my %env = $self->perlbrew_env($perl);

    if ($self->env('SHELL') =~ /(ba|k|z|\/)sh$/) {
        while (my ($k, $v) = each(%env)) {
            if (defined $v) {
                $v =~ s/(\\")/\\$1/g;
                print "export $k=\"$v\"\n";
            }
            else {
                print "unset $k\n";
            }
        }
    }
    else {
        while (my ($k, $v) = each(%env)) {
            if (defined $v) {
                $v =~ s/(\\")/\\$1/g;
                print "setenv $k \"$v\"\n";
            }
            else {
                print "unsetenv $k\n";
            }
        }
    }
}

sub run_command_symlink_executables {
    my($self, @perls) = @_;
    my $root = $self->root;

    unless (@perls) {
        @perls = map { m{/([^/]+)$} } grep { -d $_ && ! -l $_ } <$root/perls/*>;
    }

    for my $perl (@perls) {
        for my $executable (<$root/perls/$perl/bin/*>) {
            my ($name, $version) = $executable =~ m/bin\/(.+?)(5\.\d.*)?$/;
            system("ln -fs $executable $root/perls/$perl/bin/$name") if $version;
        }
    }
}

sub run_command_install_patchperl {
    my ($self) = @_;
    $self->do_install_program_from_url(
        'https://raw.github.com/gugod/patchperl-packing/master/patchperl',
        'patchperl',
        sub {
            my ($body) = @_;
            $body =~ s/\A#!.+?\n/ $self->system_perl_shebang . "\n" /se;
            return $body;
        }
    );
}

sub run_command_install_cpanm {
    my ($self) = @_;
    $self->do_install_program_from_url('https://github.com/miyagawa/cpanminus/raw/master/cpanm' => 'cpanm');
}

sub run_command_install_ack {
    my ($self) = @_;
    $self->do_install_program_from_url('http://betterthangrep.com/ack-standalone' => 'ack');
}

sub run_command_self_upgrade {
    my ($self) = @_;
    my $TMPDIR = $ENV{TMPDIR} || "/tmp";
    my $TMP_PERLBREW = catfile($TMPDIR, "perlbrew");

    unless(-w $FindBin::Bin) {
        die "Your perlbrew installation appears to be system-wide.  Please upgrade through your package manager.\n";
    }

    http_get('http://get.perlbrew.pl', undef, sub {
        my ( $body ) = @_;

        open my $fh, '>', $TMP_PERLBREW or die "Unable to write perlbrew: $!";
        print $fh $body;
        close $fh;
    });

    chmod 0755, $TMP_PERLBREW;
    my $new_version = qx($TMP_PERLBREW version);
    chomp $new_version;
    if($new_version =~ /App::perlbrew\/(\d+\.\d+)$/) {
        $new_version = $1;
    } else {
        die "Unable to detect version of new perlbrew!\n";
    }
    if($new_version <= $VERSION) {
        print "Your perlbrew is up-to-date.\n";
        return;
    }
    system $TMP_PERLBREW, "self-install";
    unlink $TMP_PERLBREW;
}

sub run_command_uninstall {
    my ( $self, $target ) = @_;

    unless($target) {
        die <<USAGE

Usage: perlbrew uninstall <name>

    The name is the installation name as in the output of `perlbrew list`

USAGE
    }

    my $dir = "@{[ $self->root ]}/perls/$target";

    if (-l $dir) {
        die "\nThe given name `$target` is an alias, not a real installation. Cannot perform uninstall.\nTo delete the alias, run:\n\n    perlbrew alias delete $target\n\n";
    }

    unless(-d $dir) {
        die "'$target' is not installed\n";
    }
    exec 'rm', '-rf', $dir;
}

sub run_command_exec {
    my $self = shift;
    my %opts;

    local (@ARGV) = @{$self->{original_argv}};

    shift @ARGV; # "exec"

    Getopt::Long::GetOptions(
        \%opts,
        'with=s',
    );

    my @exec_with = map { ($_, @{$_->{libs}}) } $self->installed_perls;

    if ($opts{with}) {
        my $d = ($opts{with} =~ / /) ? qr( +) : qr(,+);
        my %x = map { $_ => 1 } grep { $_ } map {
            my ($p,$l) = $self->resolve_installation_name($_);
            $p .= "\@$l" if $l;
            $p;
        } split $d, $opts{with};
        @exec_with = grep { $x{ $_->{name} } } @exec_with;
    }

    if (0 == @exec_with) {
        print "No perl installation found.\n" unless $self->{quiet};
    }

    for my $i ( @exec_with ) {
        next if -l $self->root . '/perls/' . $i->{name}; # Skip Aliases
        my %env = $self->perlbrew_env($i->{name});
        next if !$env{PERLBREW_PERL};

        local @ENV{ keys %env } = values %env;
        local $ENV{PATH}    = join(':', $env{PERLBREW_PATH}, $ENV{PATH});
        local $ENV{MANPATH} = join(':', $env{PERLBREW_MANPATH}, $ENV{MANPATH}||"");

        print "$i->{name}\n==========\n" unless $self->{quiet};
        $self->do_system(@ARGV);
        print "\n\n" unless $self->{quiet};
    }
}

sub run_command_clean {
    my ($self) = @_;
    my $root = $self->root;
    my @build_dirs = <$root/build/*>;

    for my $dir (@build_dirs) {
        print "Remove $dir\n";
        rmpath($dir);
    }

    print "\nDone\n";
}

sub run_command_alias {
    my ($self, $cmd, $name, $alias) = @_;

    if (!$cmd) {
        print <<USAGE;

Usage: perlbrew alias [-f] <action> <name> [<alias>]

    perlbrew alias create <name> <alias>
    perlbrew alias delete <alias>
    perlbrew alias rename <old_alias> <new_alias>

USAGE

        return;
    }

    unless ( $self->is_installed($name) ) {
        die "\nABORT: The installation `${name}` does not exist.\n\n";
    }

    my $path_name  = catfile($self->root, "perls", $name);
    my $path_alias = catfile($self->root, "perls", $alias) if $alias;

    if ($alias && -e $path_alias && !-l $path_alias) {
        die "\nABORT: The installation name `$alias` is not an alias, cannot override.\n\n";
    }

    if ($cmd eq 'create') {
        if ( $self->is_installed($alias) && !$self->{force} ) {
            die "\nABORT: The installation `${alias}` already exists. Cannot override.\n\n";
        }


        unlink($path_alias) if -e $path_alias;
        symlink($path_name, $path_alias);
    }
    elsif($cmd eq 'delete') {
        unless (-l $path_name) {
            die "\nABORT: The installation name `$name` is not an alias, cannot remove.\n\n";
        }

        unlink($path_name);
    }
    elsif($cmd eq 'rename') {
        unless (-l $path_name) {
            die "\nABORT: The installation name `$name` is not an alias, cannot rename.\n\n";
        }

        if (-l $path_alias && !$self->{force}) {
            die "\nABORT: The alias `$alias` already exists, cannot rename to it.\n\n";
        }

        rename($path_name, $path_alias);
    }
    else {
        die "\nERROR: Unrecognized action: `${cmd}`.\n\n";
    }
}

sub run_command_display_bashrc {
    print BASHRC_CONTENT();
}

sub run_command_display_cshrc {
    print CSHRC_CONTENT();
}

sub lib_usage {
    my $usage = <<'USAGE';

Usage: perlbrew lib <action> <name> [<name> <name> ...]

    perlbrew lib list
    perlbrew lib create nobita
    perlbrew lib create perl-5.14.2@nobita

    perlbrew use perl-5.14.2@nobita
    perlbrew lib delete perl-5.12.3@nobita shizuka

USAGE


    return $usage;
}

sub run_command_lib {
    my ($self, $subcommand, @args) = @_;
    unless ($subcommand) {
        print lib_usage;
        return;
    }

    my $sub = "run_command_lib_$subcommand";
    if ($self->can($sub)) {
        $self->$sub( @args );
    }
    else {
        print "Unknown command: $subcommand\n";
    }
}

sub run_command_lib_create {
    my ($self, $name) = @_;

    die "ERROR: No lib name\n", lib_usage unless $name;

    $name =~ s/^/@/ unless $name =~ /@/;

    my ($perl_name, $lib_name) = $self->resolve_installation_name($name);

    if (!$perl_name) {
        my ($perl_name, $lib_name) = split('@', $name);
        die "ERROR: '$perl_name' is not installed yet, '$name' cannot be created.\n";
    }

    my $fullname = $perl_name . '@' . $lib_name;
    my $dir = catdir($PERLBREW_HOME,  "libs", $fullname);

    if (-d $dir) {
        die "$fullname is already there.\n";
    }

    mkpath($dir);

    print "lib '$fullname' is created.\n"
        unless $self->{quiet};

    return;
}

sub run_command_lib_delete {
    my ($self, $name) = @_;

    die "ERROR: No lib to delete\n", lib_usage unless $name;

    $name =~ s/^/@/ unless $name =~ /@/;

    my ($perl_name, $lib_name) = $self->resolve_installation_name($name);

    if (!$perl_name) {
    }

    my $fullname = $perl_name . '@' . $lib_name;

    my $current  = $self->current_perl . '@' . ($self->env("PERLBREW_LIB") || "");

    my $dir = catdir($PERLBREW_HOME,  "libs", $fullname);

    if (-d $dir) {

        if ($fullname eq $current) {
            die "$fullname is currently being used in the current shell, it cannot be deleted.\n";
        }

        rmpath($dir);

        print "lib '$fullname' is deleted.\n"
            unless $self->{quiet};
    }
    else {
        die "ERROR: '$fullname' does not exist.\n";
    }

    return;
}

sub run_command_lib_list {
    my ($self) = @_;

    my $current = "";
    if ($self->current_perl && $self->env("PERLBREW_LIB")) {
        $current = $self->current_perl . "@" . $self->env("PERLBREW_LIB");
    }

    my $dir = catdir($PERLBREW_HOME,  "libs");
    return unless -d $dir;

    opendir my $dh, $dir or die "open $dir failed: $!";
    my @libs = grep { !/^\./ && /\@/ } readdir($dh);

    for (@libs) {
        print $current eq $_ ? "* " : "  ";
        print "$_\n";
    }
}

sub run_command_upgrade_perl {
    my ($self) = @_;

    my $PERL_VERSION_RE = qr/(\d+)\.(\d+)\.(\d+)/;

    my ( $current ) = grep { $_->{is_current} } $self->installed_perls;

    unless(defined $current) {
        print "no perlbrew environment is currently in use\n";
        exit 1;
    }

    my ( $major, $minor, $release );

    if($current->{version} =~ /^$PERL_VERSION_RE$/) {
        ( $major, $minor, $release ) = ( $1, $2, $3 );
    } else {
        print "unable to parse version '$current->{version}'\n";
        exit 1;
    }

    my @available = grep {
        /^perl-$major\.$minor/
    } $self->available_perls;

    my $latest_available_perl = $release;

    foreach my $perl (@available) {
        if($perl =~ /^perl-$PERL_VERSION_RE$/) {
            my $this_release = $3;
            if($this_release > $latest_available_perl) {
                $latest_available_perl = $this_release;
            }
        }
    }

    if($latest_available_perl == $release) {
        print "This perlbrew environment ($current->{name}) is already up-to-date.\n";
        exit 0;
    }

    my $dist_version = "$major.$minor.$latest_available_perl";
    my $dist         = "perl-$dist_version";

    print "Upgrading $current->{name} to $dist_version\n";
    local $self->{as}        = $current->{name};
    local $self->{dist_name} = $dist;
    $self->do_install_release($dist);
}

sub run_command_list_modules {
    my ($self) = @_;

    $self->{quiet} = 1;
    $self->{original_argv} = [
        "exec", "--with", $ENV{PERLBREW_PERL},
        'perl', '-MExtUtils::Installed', '-le', 'print for ExtUtils::Installed->new->modules'
    ];

    $self->run_command_exec();
}

sub resolve_installation_name {
    my ($self, $name) = @_;
    die "App::perlbrew->resolve_installation_name requires one argument." unless $name;

    my ($perl_name, $lib_name) = split('@', $name);
    $perl_name = $name unless $lib_name;
    $perl_name ||= $self->current_perl;

    if ( !$self->is_installed($perl_name) ) {
        if ($self->is_installed("perl-${perl_name}") ) {
            $perl_name = "perl-${perl_name}";
        }
        else {
            return undef;
        }
    }

    return wantarray ? ($perl_name, $lib_name) : $perl_name;
}


sub config {
    my($self) = @_;
    $self->_load_config if ! $CONFIG;
    return $CONFIG;
}

sub config_file {
    my ($self) = @_;
    catfile( $self->root, 'Config.pm' );
}

sub _save_config {
    my($self) = @_;
    require Data::Dumper;
    open my $FH, '>', $self->config_file or die "Unable to open config (@{[ $self->config_file ]}): $!";
    my $d = Data::Dumper->new([$CONFIG],['App::perlbrew::CONFIG']);
    print $FH $d->Dump;
    close $FH;
}

sub _load_config {
    my($self) = @_;

    if ( ! -e $self->config_file ) {
        local $CONFIG = {} if ! $CONFIG;
        $self->_save_config;
    }

    open my $FH, '<', $self->config_file or die "Unable to open config (@{[ $self->config_file ]}): $!\n";
    my $raw = do { local $/; my $rv = <$FH>; $rv };
    close $FH;

    my $rv = eval $raw;
    if ( $@ ) {
        warn "Error loading conf: $@\n";
        $CONFIG = {};
        return;
    }
    $CONFIG = {} if ! $CONFIG;
    return;
}

sub BASHRC_CONTENT() {
    return "export PERLBREW_BASHRC_VERSION=$VERSION\n\n" . <<'RC';
[[ -z "$PERLBREW_ROOT" ]] && export PERLBREW_ROOT="$HOME/perl5/perlbrew"
[[ -z "$PERLBREW_HOME" ]] && export PERLBREW_HOME="$HOME/.perlbrew"

__perlbrew_reinit () {
    if [[ ! -d "$PERLBREW_HOME" ]]; then
        mkdir -p "$PERLBREW_HOME"
    fi

    echo '# DO NOT EDIT THIS FILE' >| "$PERLBREW_HOME/init"
    command perlbrew env $1 |grep PERLBREW_ >> "$PERLBREW_HOME/init"
    . "$PERLBREW_HOME/init"
    __perlbrew_set_path
}

__perlbrew_set_path() {
    export MANPATH_WITHOUT_PERLBREW="$(perl -e 'print join ":", grep { index($_, $ENV{PERLBREW_ROOT}) } split/:/,qx(manpath -q);')"
    if [ -n "$PERLBREW_MANPATH" ]; then
        export MANPATH="$PERLBREW_MANPATH:$MANPATH_WITHOUT_PERLBREW"
    else
        export MANPATH="$MANPATH_WITHOUT_PERLBREW"
    fi

    export PATH_WITHOUT_PERLBREW="$(perl -e 'print join ":", grep { index($_, $ENV{PERLBREW_HOME}) < 0 } grep { index($_, $ENV{PERLBREW_ROOT}) < 0 } split/:/,$ENV{PATH};')"
    export PATH=${PERLBREW_PATH}:${PATH_WITHOUT_PERLBREW}
    hash -r
}

## Input: PERLBREW_PERL, PERLBREW_LIB
__perlbrew_activate() {
    [[ -n $(alias perl 2>/dev/null) ]] && unalias perl 2>/dev/null

    perlbrew_bin_path="${PERLBREW_ROOT}/bin"

    if [[ -f $perlbrew_bin_path/perlbrew ]]; then
        perlbrew_command="$perlbrew_bin_path/perlbrew"
    else
        perlbrew_command="perlbrew"
    fi

    if [[ -z "$PERLBREW_LIB" ]]; then
        eval $($perlbrew_command env $PERLBREW_PERL)
    else
        eval $(${perlbrew_command} env $PERLBREW_PERL@$PERLBREW_LIB)
    fi

    __perlbrew_set_path
}

perlbrew () {
    local exit_status
    local short_option
    export SHELL

    if [[ $1 == -* ]]; then
        short_option=$1
        shift
    else
        short_option=""
    fi

    case $1 in
        (use)
            if [[ -z "$2" ]] ; then
                if [[ -z "$PERLBREW_PERL" ]] ; then
                    echo "Currently using system perl"
                else
                    echo "Currently using $PERLBREW_PERL"
                fi
            else
                code=$(command perlbrew env $2);
                if [ -z "$code" ]; then
                    exit_status=1
                else
                    OLD_IFS=$IFS
                    IFS="$(echo -e "\n\r")"
                    for line in $code; do
                        eval $line
                    done
                    IFS=$OLD_IFS
                    __perlbrew_set_path
                fi
            fi
            ;;

        (switch)
              if [[ -z "$2" ]] ; then
                  command perlbrew switch
              else
                  perlbrew use $2 && __perlbrew_reinit $2
              fi
              ;;

        (off)
            unset PERLBREW_PERL
            __perlbrew_activate
            echo "perlbrew is turned off."
            ;;

        (switch-off)
            unset PERLBREW_PERL
            __perlbrew_reinit
            echo "perlbrew is switched off."
            ;;

        (*)
            command perlbrew $short_option "$@"
            exit_status=$?
            ;;
    esac
    hash -r
    return ${exit_status:-0}
}


if [[ ! -n "$PERLBREW_SKIP_INIT" ]]; then
    if [[ -f "$PERLBREW_HOME/init" ]]; then
        . "$PERLBREW_HOME/init"
    fi
fi

__perlbrew_activate

RC

}

sub BASH_COMPLETION_CONTENT() {
    return <<'COMPLETION';
if [[ -n ${ZSH_VERSION-} ]]; then
    autoload -U +X bashcompinit && bashcompinit
fi

export PERLBREW="command perlbrew"
_perlbrew_compgen()
{
    COMPREPLY=( $($PERLBREW compgen $COMP_CWORD ${COMP_WORDS[*]}) )
}
complete -F _perlbrew_compgen perlbrew
COMPLETION
}

sub CSH_WRAPPER_CONTENT {
    return <<'WRAPPER';
set perlbrew_exit_status=0

if ( $1 =~ -* ) then
    set perlbrew_short_option=$1
    shift
else
    set perlbrew_short_option=""
endif

switch ( $1 )
    case use:
        if ( $%2 == 0 ) then
            if ( $?PERLBREW_PERL == 0 ) then
                echo "Currently using system perl"
            else
                if ( $%PERLBREW_PERL == 0 ) then
                    echo "Currently using system perl"
                else
                    echo "Currently using $PERLBREW_PERL"
                endif
            endif
        else
            set perlbrew_line_count=0
            foreach perlbrew_line ( "`\perlbrew env $2`" )
                eval $perlbrew_line
                @ perlbrew_line_count++
            end
            if ( $perlbrew_line_count == 0 ) then
                set perlbrew_exit_status=1
            else
                source "$PERLBREW_ROOT/etc/csh_set_path"
            endif
        endif
        breaksw

    case switch:
        if ( $%2 == 0 ) then
            \perlbrew switch
        else
            perlbrew use $2 && source $PERLBREW_ROOT/etc/csh_reinit $2
        endif
        breaksw

    case off:
        unsetenv PERLBREW_PERL
        foreach perlbrew_line ( "`\perlbrew env`" )
            eval $perlbrew_line
        end
        source $PERLBREW_ROOT/etc/csh_set_path
        echo "perlbrew is turned off."
        breaksw

    case switch-off:
        unsetenv PERLBREW_PERL
        source $PERLBREW_ROOT/etc/csh_reinit ''
        echo "perlbrew is switched off."
        breaksw

    default:
        \perlbrew $perlbrew_short_option $argv
        set perlbrew_exit_status=$?
        breaksw
endsw
rehash
exit $perlbrew_exit_status
WRAPPER
}

sub CSH_REINIT_CONTENT {
    return <<'REINIT';
if ( ! -d "$PERLBREW_HOME" ) then
    mkdir -p "$PERLBREW_HOME"
endif

echo '# DO NOT EDIT THIS FILE' >! "$PERLBREW_HOME/init"
\perlbrew env $1 >> "$PERLBREW_HOME/init"
source "$PERLBREW_HOME/init"
source "$PERLBREW_ROOT/etc/csh_set_path"
REINIT
}

sub CSH_SET_PATH_CONTENT {
    return <<'SETPATH';
unalias perl

if ( $?PERLBREW_PATH == 0 ) then
    setenv PERLBREW_PATH "$PERLBREW_ROOT/bin"
endif

setenv PATH_WITHOUT_PERLBREW `perl -e 'print join ":", grep { index($_, $ENV{PERLBREW_ROOT}) } split/:/,$ENV{PATH};'`
setenv PATH ${PERLBREW_PATH}:${PATH_WITHOUT_PERLBREW}

setenv MANPATH_WITHOUT_PERLBREW `perl -e 'print join ":", grep { index($_, $ENV{PERLBREW_ROOT}) } split/:/,qx(manpath);'`
if ( $?PERLBREW_MANPATH == 1 ) then
    setenv MANPATH ${PERLBREW_MANPATH}:${MANPATH_WITHOUT_PERLBREW}
else
    setenv MANPATH ${MANPATH_WITHOUT_PERLBREW}
endif
SETPATH
}

sub CSHRC_CONTENT {
    return "setenv PERLBREW_CSHRC_VERSION $VERSION\n\n" . <<'CSHRC';

if ( $?PERLBREW_HOME == 0 ) then
    setenv PERLBREW_HOME "$HOME/.perlbrew"
endif

if ( $?PERLBREW_ROOT == 0 ) then
    setenv PERLBREW_ROOT "$HOME/perl5/perlbrew"
endif

if ( $?PERLBREW_SKIP_INIT == 0 ) then
    if ( -f "$PERLBREW_HOME/init" ) then
        source "$PERLBREW_HOME/init"
    endif
endif

if ( $?PERLBREW_PATH == 0 ) then
    setenv PERLBREW_PATH "$PERLBREW_ROOT/bin"
endif

source "$PERLBREW_ROOT/etc/csh_set_path"
alias perlbrew 'source $PERLBREW_ROOT/etc/csh_wrapper'
CSHRC
}

1;

__END__

=encoding utf8

=head1 NAME

App::perlbrew - Manage perl installations in your $HOME

=head1 SYNOPSIS

    # Installation
    curl -kL http://install.perlbrew.pl | bash

    # Initialize
    perlbrew init

    # Pick a preferred CPAN mirror
    perlbrew mirror

    # See what is available
    perlbrew available

    # Install some Perls
    perlbrew install 5.14.0
    perlbrew install perl-5.8.1
    perlbrew install perl-5.13.6

    # See what were installed
    perlbrew list

    # Switch perl in the $PATH
    perlbrew switch perl-5.12.2
    perl -v

    # Temporarily use another version only in current shell.
    perlbrew use perl-5.8.1
    perl -v

    # Or turn it off completely. Useful when you messed up too deep.
    # Or want to go back to the system Perl.
    perlbrew off

    # Use 'switch' command to turn it back on.
    perlbrew switch perl-5.12.2

    # Exec something with all perlbrew-ed perls
    perlbrew exec perl -E 'say $]'

=head1 DESCRIPTION

perlbrew is a program to automate the building and installation of perl in an
easy way. It installs everything to C<~/perl5/perlbrew>, and requires you to
tweak your PATH by including a bashrc/cshrc file it provides. You then can
benefit from not having to run 'sudo' commands to install cpan modules because
those are installed inside your HOME too. It provides multiple isolated perl
environments, and a mechanism for you to switch between them.

For the documentation of perlbrew usage see L<perlbrew> command
on CPAN, or by running C<perlbrew help>. The following documentation
features the API of C<App::perlbrew> module, and may not be remotely
close to what your want to read.

=head1 INSTALLATION

It is the simpleist to use the perlbrew installer, just paste this statement to
your terminal:

    curl -kL http://install.perlbrew.pl | bash

Or this one, if you have C<fetch> (default on FreeBSD):

    fetch -o- http://install.perlbrew.pl | sh

After that, C<perlbrew> installs itself to C<~/perl5/perlbrew/bin>, and you
should follow the instruction on screen to modify your shell rc file to put it
in your PATH.

The installed perlbrew command is a standalone executable that can be run with
system perl. The minimun system perl version requirement is 5.8.0, which should
be good enough for most of the OSes these days.

A packed version of C<patchperl> to C<~/perl5/perlbrew/bin>, which is required
to build old perls.

The directory C<~/perl5/perlbrew> will contain all install perl executables,
libraries, documentations, lib, site_libs. In the documentation, that directory
is referred as "perlbrew root". If you need to set it to somewhere else because,
say, your HOME has limited quota, you can do that by setting C<PERLBREW_ROOT>
environment variable before running the installer:

    export PERLBREW_ROOT=/opt/perl5
    curl -kL http://install.perlbrew.pl | bash

You may also install perlbrew from CPAN:

    cpan App::perlbrew

In this case, the perlbrew command is installed as C</usr/bin/perlbrew> or
C</usr/local/bin/perlbrew> or others, depending on the location of your system
perl installation.

Please make sure not to run this with one of the perls brewed with
perlbrew. It's the best to turn perlbrew off before you run that, if you're
upgrading.

    perlbrew off
    cpan App::perlbrew

You should always use system cpan (like /usr/bin/cpan) to install
C<App::perlbrew> because it will be installed under a system PATH like
C</usr/bin>, which is not affected by perlbrew C<switch> or C<use> command.

The C<self-upgrade> command will not upgrade the perlbrew installed by cpan
command, but it is also easy to upgrade perlbrew by running `cpan App::perlbrew`
again.

=head1 METHODS

=over 4

=item (Str) current_perl

Return the "current perl" object attribute string, or, if absent, the value of
PERLBREW_PERL environment variable.

=item (Str) current_perl (Str)

Set the "current_perl" object attribute to the given value.

=back

=head1 PROJECT DEVELOPMENT

perlbrew project uses github
L<http://github.com/gugod/App-perlbrew/issues> and RT
<https://rt.cpan.org/Dist/Display.html?Queue=App-perlbrew> for issue
tracking. Issues sent to these two systems will eventually be reviewed
and handled.

See L<https://github.com/gugod/App-perlbrew/contributors> for a list
of project contributors.

=head1 AUTHOR

Kang-min Liu  C<< <gugod@gugod.org> >>

=head1 COPYRIGHT

Copyright (c) 2010, 2011, 2012 Kang-min Liu C<< <gugod@gugod.org> >>.

=head1 LICENCE

The MIT License

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
