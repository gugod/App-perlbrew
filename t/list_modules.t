#!/usr/bin/env perl
use Test2::V0;
use Test2::Tools::Spec;

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require "test2_helpers.pl";

mock_perlbrew_install("perl-5.14.1");

subtest "list_modules method," => sub {
    before_each => sub {
        delete $ENV{PERL_MB_OPT};
        delete $ENV{PERL_MM_OPT};
        delete $ENV{PERL_LOCAL_LIB_ROOT};
        delete $ENV{PERLBREW_LIB};
        delete $ENV{PERL5LIB};
    };

    subtest "when run successfully", sub {
        before_each => sub {
            no warnings;
            sub App::perlbrew::run_command_exec {
                my ($self, @args) = @_;
                if (grep { $_ eq '-MExtUtils::Installed' } @args) {
                    print "Foo\n";
                } else {
                    die "Unexpected `exec`";
                }
                return $self;
            }
        };

        subtest "it should return an arryref of module names ", sub {
            my $app = App::perlbrew->new();
            $app->current_perl("perl-5.14.1");
            my $modules = $app->list_modules();
            is 0+@$modules, 1;
            is $modules->[0], "Foo";
        };
    };
};

done_testing;
