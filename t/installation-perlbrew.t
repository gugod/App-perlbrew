#!/usr/bin/env perl
use Test2::V0;

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require 'test2_helpers.pl';

use Capture::Tiny qw( capture_stdout );

note "PERLBREW_ROOT set to $ENV{PERLBREW_ROOT}";

subtest "`perlbrew self-install` initialize the required dir structure under PERLBREW_ROOT", sub {
    my $app = App::perlbrew->new('--quiet', 'self-install');
    $app->run;

    ok -d dir($ENV{PERLBREW_ROOT}, "bin");
    ok -d dir($ENV{PERLBREW_ROOT}, "etc");
    ok -d dir($ENV{PERLBREW_ROOT}, "perls");
    ok -d dir($ENV{PERLBREW_ROOT}, "dists");
    ok -d dir($ENV{PERLBREW_ROOT}, "build");

    ok -f file($ENV{PERLBREW_ROOT}, "bin", "perlbrew");
    ok -f file($ENV{PERLBREW_ROOT}, "etc", "bashrc");
    ok -f file($ENV{PERLBREW_ROOT}, "etc", "cshrc");
    ok -f file($ENV{PERLBREW_ROOT}, "etc", "csh_reinit");
    ok -f file($ENV{PERLBREW_ROOT}, "etc", "csh_set_path");
    ok -f file($ENV{PERLBREW_ROOT}, "etc", "csh_wrapper");
};

subtest "Works with bash", sub {
    if ($ENV{PERLBREW_SHELLRC_VERSION}) {
        skip_all "PERLBREW_SHELLRC_VERSION is defined, thus this subtest makes little sense.";
        return;
    }

    my $out = capture_stdout {
        my $app = App::perlbrew->new('self-install');
        $app->current_shell("bash");
        $app->run;
    };
    like($out, qr|    export PERLBREW_HOME=\S+|);
    like($out, qr|    source \S+/etc/bashrc|);
};

subtest "Works with fish", sub {
    if ($ENV{PERLBREW_SHELLRC_VERSION}) {
        skip_all "PERLBREW_SHELLRC_VERSION is defined, thus this subtest makes little sense.";
        return;
    }

    my $out = capture_stdout {
        my $app = App::perlbrew->new('self-install');
        $app->current_shell("fish");
        $app->run;
    };
    like($out, qr|    set -x PERLBREW_HOME \S+|);
    like($out, qr|    . \S+/etc/perlbrew.fish|);
};

subtest "Works with zsh", sub {
    if ($ENV{PERLBREW_SHELLRC_VERSION}) {
        skip_all "PERLBREW_SHELLRC_VERSION is defined, thus this subtest makes little sense.";
        return;
    }
    my $out = capture_stdout {
        my $app = App::perlbrew->new('self-install');
        $app->current_shell("zsh4");
        $app->run;
    };
    like($out, qr|    export PERLBREW_HOME=\S+|);
    like($out, qr|    source \S+/etc/bashrc|);
};

subtest "Exports PERLBREW_HOME when needed", sub {
    if ($ENV{PERLBREW_SHELLRC_VERSION}) {
        skip_all "PERLBREW_SHELLRC_VERSION is defined, thus this subtest makes little sense.";
        return;
    }
    my $out = capture_stdout {
        local $App::perlbrew::PERLBREW_HOME = App::Perlbrew::Path->new ($ENV{HOME}, ".perlbrew");
        my $app = App::perlbrew->new('self-install');
        $app->current_shell("bash");
        $app->run;
    };
    unlike($out, qr|PERLBREW_HOME=\S+|);
    like($out, qr|    source \S+/etc/bashrc|);
};


done_testing;
