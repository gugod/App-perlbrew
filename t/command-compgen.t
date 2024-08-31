#!/usr/bin/env perl
use Test2::V0;
use Test2::Tools::Spec;

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require "test2_helpers.pl";
use PerlbrewTestHelpers qw( stdout_from );

$ENV{PERLBREW_DEBUG_COMPLETION} = 0;

my @perls = qw(
    perl-5.12.3
    perl-5.12.4
    perl-5.14.1
    perl-5.14.2
);
mock_perlbrew_install($_) for @perls;

{
    no warnings 'redefine';
    sub App::perlbrew::current_perl { "perl-5.12.3" }
}

describe "compgen command," => sub {
    describe "when there is no args", sub {
        it "displays a list of subcommands", sub {
            my $app = App::perlbrew->new("compgen");

            my $out = stdout_from { $app->run; };

            my @subcommands = sort split ' ', $out;
            is join(' ', @subcommands), join(' ', sort $app->commands());
        };
    };
    describe "when there is a part of a subcommand", sub {
        it "displays a list of l*", sub {
            my $part = "l";
            my $app = App::perlbrew->new("compgen", 1, 'perlbrew',  $part);

            my $out = stdout_from { $app->run; };

            my @subcommands = sort split ' ', $out;
            is join(' ', @subcommands),
               join(' ', sort grep { /\A \Q$part\E /xms } $app->commands());
        };
        it "'versio[tab]' is completed as 'version'", sub {
            my $part = "versio";
            my $app = App::perlbrew->new("compgen", 1, 'perlbrew',  $part);

            my $out = stdout_from { $app->run; };

            my @subcommands = sort split ' ', $out;
            is join(' ', @subcommands),
               join(' ', 'version');
        };
    };
    foreach my $use(qw(use switch)) {
        describe "given '$use' subcommand", sub {
            it "'use [tab]' suggests a list of installed perls", sub {
                my $app = App::perlbrew->new(
                    "compgen", 2, 'perlbrew', 'use');

                my $out = stdout_from { $app->run; };

                my @subcommands = sort split ' ', $out;
                is join(' ', @subcommands),
                   join(' ', sort @perls);
            };
            it "'use 5.12 [tab]' suggests perls with /5\\.12/", sub {
                my $app = App::perlbrew->new(
                    "compgen", 2, 'perlbrew', 'use', '5.12');

                my $out = stdout_from { $app->run; };

                my @subcommands = sort split ' ', $out;
                is join(' ', @subcommands),
                   join(' ', sort( qw(perl-5.12.3 perl-5.12.4) ));
            };
        };
    }
};

done_testing;
