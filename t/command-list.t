#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require "test_helpers.pl";

use File::Temp qw( tempdir );
use File::Spec::Functions qw( catdir );
use File::Path::Tiny;
use Test::Spec;
use Test::Output qw(stdout_is stdout_from);

mock_perlbrew_install("perl-5.12.3");
mock_perlbrew_install("perl-5.12.4");
mock_perlbrew_install("perl-5.14.1");
mock_perlbrew_install("perl-5.14.2");

{
    no warnings 'redefine';
    sub App::perlbrew::current_perl { "perl-5.12.3" }
}

describe "list command," => sub {
    my $app;

    describe "when there no libs under PERLBREW_HOME,", sub {
        it "displays a list of perl installation names", sub {
            $app = App::perlbrew->new("list");

            my $out = stdout_from { $app->run; };

            ## Remove paths to system perl from the list
            $out =~ s/^[* ] \/.+$//mg;
            $out =~ s/\n\n+/\n/;

            is $out, <<"EOF";
* perl-5.12.3
  perl-5.12.4
  perl-5.14.1
  perl-5.14.2
EOF
        };
    };

    describe "when there are lib under PERLBREW_HOME,", sub {
        before each => sub {
            stdout_is {
                App::perlbrew->new("lib", "create", "nobita")->run;
                App::perlbrew->new("lib", "create", "shizuka")->run;
            } <<'OUT';
lib 'perl-5.12.3@nobita' is created.
lib 'perl-5.12.3@shizuka' is created.
OUT
        };

        it "displays lib names" => sub {
            $app = App::perlbrew->new("list");

            my $out = stdout_from { $app->run };

            ## Remove paths to system perl from the list
            $out =~ s/^[* ] \/.+$//mg;
            $out =~ s/\n\n+/\n/;

            is $out, <<'OUT';
* perl-5.12.3
  perl-5.12.3@nobita
  perl-5.12.3@shizuka
  perl-5.12.4
  perl-5.14.1
  perl-5.14.2
OUT
        };
    };
};

runtests unless caller;

