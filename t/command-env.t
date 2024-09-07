#!/usr/bin/env perl
use Test2::V0;
use Test2::Tools::Spec;
use Config;

BEGIN { $ENV{SHELL} = "/bin/bash" }

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require "test2_helpers.pl";
use PerlbrewTestHelpers qw(stdout_is);

mock_perlbrew_install("perl-5.14.1");
mock_perlbrew_lib_create('perl-5.14.1@nobita');

describe "env command," => sub {
    before_each 'cleanup env' => sub {
        delete $ENV{PERL_MB_OPT};
        delete $ENV{PERL_MM_OPT};
        delete $ENV{PERL_LOCAL_LIB_ROOT};
        delete $ENV{PERLBREW_LIB};
        delete $ENV{PERL5LIB};
        delete $ENV{PERLBREW_LIB_PREFIX};
    };

    describe "when invoked with a perl installation name,", sub {
        it "displays environment variables that should be set to use the given perl." => sub {
            my $app = App::perlbrew->new("env", "perl-5.14.1");

            stdout_is {
                $app->run;
            } <<"OUT";
unset PERL5LIB
unset PERLBREW_LIB
export PERLBREW_MANPATH="$App::perlbrew::PERLBREW_ROOT/perls/perl-5.14.1/man"
export PERLBREW_PATH="$App::perlbrew::PERLBREW_ROOT/bin:$App::perlbrew::PERLBREW_ROOT/perls/perl-5.14.1/bin"
export PERLBREW_PERL="perl-5.14.1"
export PERLBREW_ROOT="$App::perlbrew::PERLBREW_ROOT"
export PERLBREW_VERSION="$App::perlbrew::VERSION"
unset PERL_LOCAL_LIB_ROOT
OUT
        };
    };

    describe "when invoked with a perl installation name with lib name,", sub {
        it "displays local::lib-related environment variables that should be set to use the given perl." => sub {
            note 'perlbrew env perl-5.14.1@nobita';

            my $PERL5LIB_maybe = $ENV{PERL5LIB} ? ":\$PERL5LIB" : "";
            my $app = App::perlbrew->new("env", 'perl-5.14.1@nobita');

            my $lib_dir = "$App::perlbrew::PERLBREW_HOME/libs/perl-5.14.1\@nobita";
            stdout_is {
                $app->run;
            } <<"OUT";
export PERL5LIB="$lib_dir/lib/perl5${PERL5LIB_maybe}"
export PERLBREW_LIB="nobita"
export PERLBREW_MANPATH="$lib_dir/man:$App::perlbrew::PERLBREW_ROOT/perls/perl-5.14.1/man"
export PERLBREW_PATH="$lib_dir/bin:$App::perlbrew::PERLBREW_ROOT/bin:$App::perlbrew::PERLBREW_ROOT/perls/perl-5.14.1/bin"
export PERLBREW_PERL="perl-5.14.1"
export PERLBREW_ROOT="$App::perlbrew::PERLBREW_ROOT"
export PERLBREW_VERSION="$App::perlbrew::VERSION"
export PERL_LOCAL_LIB_ROOT="$lib_dir"
export PERL_MB_OPT="--install_base "$lib_dir""
export PERL_MM_OPT="INSTALL_BASE=$lib_dir"
OUT
        }
    };

    describe "when invoked with a perl installation name with lib name and PERLBREW_LIB_PREFIX set,", sub {
        it "displays PERL5LIB with PERLBREW_LIB_PREFIX value first." => sub {
            note 'perlbrew env perl-5.14.1@nobita';

            $ENV{PERLBREW_LIB_PREFIX} = 'perlbrew_lib_prefix';

            my $PERL5LIB_maybe = $ENV{PERL5LIB} ? ":\$PERL5LIB" : "";
            my $app = App::perlbrew->new("env", 'perl-5.14.1@nobita');

            my $lib_dir = "$App::perlbrew::PERLBREW_HOME/libs/perl-5.14.1\@nobita";
            stdout_is {
                $app->run;
            } <<"OUT";
export PERL5LIB="$ENV{PERLBREW_LIB_PREFIX}:$lib_dir/lib/perl5${PERL5LIB_maybe}"
export PERLBREW_LIB="nobita"
export PERLBREW_MANPATH="$lib_dir/man:$App::perlbrew::PERLBREW_ROOT/perls/perl-5.14.1/man"
export PERLBREW_PATH="$lib_dir/bin:$App::perlbrew::PERLBREW_ROOT/bin:$App::perlbrew::PERLBREW_ROOT/perls/perl-5.14.1/bin"
export PERLBREW_PERL="perl-5.14.1"
export PERLBREW_ROOT="$App::perlbrew::PERLBREW_ROOT"
export PERLBREW_VERSION="$App::perlbrew::VERSION"
export PERL_LOCAL_LIB_ROOT="$lib_dir"
export PERL_MB_OPT="--install_base "$lib_dir""
export PERL_MM_OPT="INSTALL_BASE=$lib_dir"
OUT
        }
    }
};

done_testing;
