#!/usr/bin/env perl
#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { $ENV{SHELL} = "/bin/bash" }

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require "test_helpers.pl";

use File::Temp qw( tempdir );
use File::Spec::Functions qw( catdir );
use Test::Spec;
use Test::Output;
use Config;

mock_perlbrew_install("perl-5.14.1");
mock_perlbrew_lib_create('perl-5.14.1@nobita');

describe "alias command," => sub {
    before each => sub {
        delete $ENV{PERL_MB_OPT};
        delete $ENV{PERL_MM_OPT};
        delete $ENV{PERL_LOCAL_LIB_ROOT};
        delete $ENV{PERLBREW_LIB};
        delete $ENV{PERL5LIB};
    };

    describe "when invoked with unknown action name,", sub {
        it "should display usage message" => sub {
            my $x   = "correcthorsebatterystaple";
            my $app = App::perlbrew->new("alias", $x);
            stderr_like {
                eval {
                    $app->run;
                    1;
                }
                or do {
                    print STDERR $@;
                };
            } qr/ERROR: Unrecognized action: `$x`/;

        }
    };
};

runtests unless caller;
