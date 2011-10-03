#!/usr/bin/env perl
use strict;
use warnings;
use File::Temp qw( tempdir );
use File::Spec::Functions qw( catdir );
use Test::Spec;
use Test::Output;
use App::perlbrew;

$App::perlbrew::PERLBREW_ROOT = tempdir( CLEANUP => 1 );
$App::perlbrew::PERLBREW_HOME = tempdir( CLEANUP => 1 );

describe "lib command," => sub {
    it "shows a page of usage synopsis when no sub-command are given." => sub {
        stdout_like {
            App::perlbrew->new("lib")->run;

        } qr/usage/i;
    };

    describe "`create` sub-command," => sub {
        it "creates the local::lib folder" => sub {
            stdout_is {
                my $app = App::perlbrew->new("lib", "create", "nobita");
                $app->expects("current_perl")->returns("perl-5.14.2");
                $app->run;
            } qq{lib 'perl-5.14.2\@nobita' is created.\n};

            ok -d catdir($App::perlbrew::PERLBREW_HOME, "libs", 'perl-5.14.2@nobita');
        };
    };

    describe "`delete` sub-command," => sub {
        before each => sub {
            App::perlbrew::mkpath(
                catdir($App::perlbrew::PERLBREW_HOME, "libs", 'perl-5.14.2@nobita')
            );
        };

        it "deletes the local::lib folder" => sub {
            stdout_is {
                my $app = App::perlbrew->new("lib", "delete", "nobita");
                $app->expects("current_perl")->returns("perl-5.14.2");
                $app->run;
            } qq{lib 'perl-5.14.2\@nobita' is deleted.\n};

            ok !-d catdir($App::perlbrew::PERLBREW_HOME, "libs", 'perl-5.14.2@nobita');
            ok !-e catdir($App::perlbrew::PERLBREW_HOME, "libs", 'perl-5.14.2@nobita');
        };
    };
};

runtests unless caller;

