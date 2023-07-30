package App::Perlbrew::HTTP;
use strict;
use warnings;
use 5.008;

use Exporter 'import';
our @EXPORT_OK = qw(http_user_agent_program http_user_agent_command http_get http_download);

our $HTTP_VERBOSE = 0;
our $HTTP_USER_AGENT_PROGRAM;

my %commands = (
    curl => {
        test     => '--version >/dev/null 2>&1',
        get      => '--silent --location --fail -o - {url}',
        download => '--silent --location --fail -o {output} {url}',
        order    => 1,

        # Exit code is 22 on 404s etc
        die_on_error => sub { die 'Page not retrieved; HTTP error code 400 or above.' if ($_[ 0 ] >> 8 == 22); },
    },
    wget => {
        test     => '--version >/dev/null 2>&1',
        get      => '--quiet -O - {url}',
        download => '--quiet -O {output} {url}',
        order    => 2,

        # Exit code is not 0 on error
        die_on_error => sub { die 'Page not retrieved: fetch failed.' if ($_[ 0 ]); },
    },
    fetch => {
        test     => '--version >/dev/null 2>&1',
        get      => '-o - {url}',
        download => '-o {output} {url}',
        order    => 3,

        # Exit code is 8 on 404s etc
        die_on_error => sub { die 'Server issued an error response.' if ($_[ 0 ] >> 8 == 8); },
    }
);

sub http_user_agent_program {
    $HTTP_USER_AGENT_PROGRAM ||= do {
        my $program;

        for my $p (sort {$commands{$a}{order}<=>$commands{$b}{order}} keys %commands) {
            my $code = system("$p $commands{$p}->{test}") >> 8;
            if ($code != 127) {
                $program = $p;
                last;
            }
        }

        unless ($program) {
            die "[ERROR] Cannot find a proper http user agent program. Please install curl or wget.\n";
        }

        $program;
    };

    die "[ERROR] Unrecognized http user agent program: $HTTP_USER_AGENT_PROGRAM. It can only be one of: ".join(",", keys %commands)."\n" unless $commands{$HTTP_USER_AGENT_PROGRAM};

    return $HTTP_USER_AGENT_PROGRAM;
}

sub http_user_agent_command {
    my ($purpose, $params) = @_;
    my $ua = http_user_agent_program;
    my $cmd = $commands{ $ua }->{ $purpose };
    for (keys %$params) {
        $cmd =~ s!{$_}!\Q$params->{$_}\E!g;
    }

    if ($HTTP_VERBOSE) {
        unless ($ua eq "fetch") {
            $cmd =~ s/(silent|quiet)/verbose/;
        }
    }

    $cmd = $ua . " " . $cmd;
    return ($ua, $cmd) if wantarray;
    return $cmd;
}

sub http_download {
    my ($url, $path) = @_;

    if (-e $path) {
        die "ERROR: The download target < $path > already exists.\n";
    }

    my $partial = 0;
    local $SIG{TERM} = local $SIG{INT} = sub { $partial++ };

    my $download_command = http_user_agent_command(download => { url => $url, output => $path });

    my $status = system($download_command);
    if ($partial) {
        $path->unlink;
        return "ERROR: Interrupted.";
    }
    unless ($status == 0) {
        $path->unlink;
        if ($? == -1) {
            return "ERROR: Failed to execute the command\n\n\t$download_command\n\nReason:\n\n\t$!";
        }
        elsif ($? & 127) {
            return "ERROR: The command died with signal " . ($? & 127) . "\n\n\t$download_command\n\n";
        }
        else {
            return "ERROR: The command finished with error\n\n\t$download_command\n\nExit code:\n\n\t" . ($? >> 8);
        }
    }
    return 0;
}

sub http_get {
    my ($url, $header, $cb) = @_;

    if (ref($header) eq 'CODE') {
        $cb = $header;
        $header = undef;
    }

    my ($program, $command) = http_user_agent_command(get => { url =>  $url });

    open my $fh, '-|', $command
    or die "open() pipe for '$command': $!";

    local $/;
    my $body = <$fh>;
    close $fh;

    # check if the download has failed and die automatically
    $commands{ $program }{ die_on_error }->($?);

    return $cb ? $cb->($body) : $body;
}

1;
