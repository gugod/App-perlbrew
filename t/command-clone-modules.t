#!/usr/bin/env perl
use Test2::V0;
use Test2::Tools::Spec;

BEGIN { $ENV{SHELL} = "/bin/bash" }

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require "test2_helpers.pl";

mock_perlbrew_install("perl-5.14.1");
mock_perlbrew_install("perl-5.16.0");

no warnings;
my ($__from, $__to, $__notest);
sub App::perlbrew::list_modules {
    my ($self, $env)  = @_;
    $__from = $env || $self->current_env;
    return ["Foo", "Bar"];
}

sub App::perlbrew::run_command_exec {
    my ($self, @args) = @_;
    if (grep { $_ eq 'cpanm' } @args) {
        $__to = $args[1];
        ($__notest) = grep { $_ eq '--notest' } @{$self->{original_argv}};
    }
    return $self;
}
use warnings;

describe "clone-modules command," => sub {
    before_each 'cleanup env' => sub {
        delete $ENV{PERL_MB_OPT};
        delete $ENV{PERL_MM_OPT};
        delete $ENV{PERL_LOCAL_LIB_ROOT};
        delete $ENV{PERLBREW_LIB};
        delete $ENV{PERL5LIB};
        $__from = undef;
        $__to = undef;
        $__notest = undef;
    };

    describe "when invoked with two arguments, A and B", sub {
        it "should display clone modules from A to B", sub {
            my $app = App::perlbrew->new(
                "clone-modules", "perl-5.14.1", "perl-5.16.0"
            );
            $app->run;
            is $__from, "perl-5.14.1";
            is $__to, "perl-5.16.0";
            ok(!defined($__notest));
        };
    };

    describe "when invoked with two arguments, A and B, with `--notest`", sub {
        it "should display clone modules from A to B", sub {
            my $app = App::perlbrew->new(
                "clone-modules", "--notest", "perl-5.14.1", "perl-5.16.0"
            );
            $app->run;
            is $__from, "perl-5.14.1";
            is $__to, "perl-5.16.0";
            ok(defined($__notest));
        };
    };

    describe "when invoked with one argument X", sub {
        it "should display clone modules from current-perl to X", sub {
            my $app = App::perlbrew->new("clone-modules", "perl-5.14.1");

            my $mock = mocked($app)->expects("current_env")->returns("perl-5.16.0")->at_least(1);
            $app->run;

            is $__from, "perl-5.16.0";
            is $__to, "perl-5.14.1";
            ok(!defined($__notest));

            $mock->verify;
        };
    };

    describe "when invoked with one argument X, with `--notest`", sub {
        it "should display clone modules from current-perl to X", sub {
            my $app = App::perlbrew->new("clone-modules", "--notest", "perl-5.14.1");
            my $mock = mocked($app)->expects("current_env")->returns("perl-5.16.0")->at_least(1);
            $app->run;

            is $__from, "perl-5.16.0";
            is $__to, "perl-5.14.1";
            ok(defined($__notest));
            $mock->verify;
        };
    };
};

done_testing;
