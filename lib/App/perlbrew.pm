package App::perlbrew;
use strict;

our $VERSION = "0.01";

local $\ = "\n";

my $ROOT = "$ENV{HOME}/perl5/perlbrew";

sub run_command {
    my (undef, $x, @args) = @_;
    my $self = bless {}, __PACKAGE__;

    $x ||= "help";
    my $s = $self->can("run_command_$x") or die "Unknow command: `$x`. Typo?\n";
    $self->$s(@args);
}

sub run_command_help {
    print <<HELP;

Usage:

    perlbrew init
    perlbrew install perl-5.11.1
    perlbrew installed
    perlbrew switch perl-5.11.1

HELP
}

sub run_command_init {
    require File::Path;
    File::Path::make_path(
        "$ROOT/perls",
        "$ROOT/dists",
        "$ROOT/build",
        "$ROOT/etc",
        "$ROOT/bin"
    );

    system <<RC;
echo 'export PATH=$ROOT/perls/bin:$ROOT/perls/current/bin:\${PATH}' > $ROOT/etc/bashrc
RC

    print "\nPerlbrew environmet Initiated. Required directories are created under $ROOT.";
    print "Please add this to the end of your ~/.bashrc:\n";
    print "    source $ROOT/etc/bashrc\n";
}

sub run_command_install {
    my ($self, $dist) = @_;

    my ($dist_name, $dist_version) = $dist =~ m/^(.*)-([\d.]+)$/;
    if ($dist_name eq 'perl') {
        require LWP::UserAgent;
        my $ua = LWP::UserAgent->new;

        print "Fetching $dist...";
        my $r = $ua->get("http://search.cpan.org/dist/$dist");
        die "Fail to fetch the dist of $dist." unless $r->is_success;

        my $html = $r->content;
        my ($dist_path, $dist_tarball) = $html =~ m[<a href="(/CPAN/authors/id/.+/(${dist}.tar.(gz|bz2)))">Download</a>];

        $r = $ua->get("http://search.cpan.org/${dist_path}",
                      ":content_file" => "$ROOT/dists/${dist_tarball}");
        die "Fail to fetch the dist of $dist." unless $r->is_success;

        my $usedevel = $dist_version =~ /5\.11/ ? "-Dusedevel" : "";
        print "Installing $dist...";

        my $tarx = "tar " . ($dist_tarball =~ /bz2/ ? "xjf" : "xzf");
        system(join ";",
            "cd $ROOT/build",
            "$tarx $ROOT/dists/${dist_tarball}",
            "cd $dist",
            "rm -f config.sh Policy.sh",
            "sh Configure -de -Dprefix=$ROOT/perls/$dist ${usedevel}",
            "make",
            "make test && make install"
        );
    }
}

sub run_command_installed {
    my $self = shift;
    for (<$ROOT/perls/perl-*>) {
        my ($name) = $_ =~ m/(perl-.+)$/;
        print $name;
    }
}

sub run_command_switch {
    my ($self, $dist) = @_;
    die "${dist} is not installed\n" unless -d "$ROOT/perls/${dist}";
    my ($dist_name, $dist_version) = $dist =~ m/^(.*)-([\d.]+)$/;
    unlink "$ROOT/perls/current";
    system "cd $ROOT/perls; ln -s $dist current";
    for my $executable (<$ROOT/perls/current/bin/*${dist_version}>) {
        my ($name) = $executable =~ m/bin\/(.+)${dist_version}/;
        system("ln -fs $executable $ROOT/bin/${name}");
    }
}

1;
