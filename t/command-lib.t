#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;

use File::Spec::Functions qw( catdir );
use File::Path::Tiny;
use Test::Spec;
use Test::Output;
use Test::Exception;
use App::perlbrew;

require "test_helpers.pl";
mock_perlbrew_install("perl-5.14.1");
mock_perlbrew_install("perl-5.14.2");
mock_perlbrew_install("perl-5.14.3");

describe "lib command," => sub {
    it "shows a page of usage synopsis when no sub-command are given." => sub {
        stdout_like {
            App::perlbrew->new("lib")->run;

        } qr/usage/i;
    };

    describe "without lib name" => sub {
        it "create errs gracefully showing usage" => sub {
            my $app = App::perlbrew->new;
            throws_ok {
                $app->{args} = [ "lib", "create"];
                $app->run;
            } qr/ERROR: /i;
        };
        it "delte errs gracefully showing usage" => sub {
            my $app = App::perlbrew->new;
            throws_ok {
                $app->{args} = [ "lib", "delete"];
                $app->run;
            } qr/ERROR: /i;
        };
    };


    describe "`create` sub-command," => sub {
        my ($app, $libdir);

        before each => sub {
            $app = App::perlbrew->new;
            $app->expects("current_perl")->returns("perl-5.14.2")->at_least_once;

            $libdir = dir($App::perlbrew::PERLBREW_HOME, "libs", 'perl-5.14.2@nobita');
        };

        after each => sub {
            $libdir->rmtree;
        };

        describe "with a bare lib name," => sub {
            it "creates the lib folder for current perl" => sub {
                stdout_is {
                    $app->{args} = [ "lib", "create", "nobita" ];
                    $app->run;
                } qq{lib 'perl-5.14.2\@nobita' is created.\n};

                ok -d $libdir;
            };
        };

        describe "with \@ in the beginning of lib name," => sub {
            it "creates the lib folder for current perl" => sub {
                stdout_is {
                    $app->{args} = [ "lib", "create", '@nobita' ];

                    $app->run;
                } qq{lib 'perl-5.14.2\@nobita' is created.\n};

                ok -d $libdir;
            }
        };

        describe "with perl name and \@  as part of lib name," => sub {
            it "creates the lib folder for the specified perl" => sub {
                stdout_is {
                    $app->{args} = [ "lib", "create", 'perl-5.14.2@nobita' ];
                    $app->run;
                } qq{lib 'perl-5.14.2\@nobita' is created.\n};

                ok -d $libdir;
            };

            it "creates the lib folder for the specified perl" => sub {
                stdout_is {
                    $app->{args} = [ "lib", "create", 'perl-5.14.1@nobita' ];
                    $app->run;
                } qq{lib 'perl-5.14.1\@nobita' is created.\n};

                $libdir = dir($App::perlbrew::PERLBREW_HOME, "libs", 'perl-5.14.1@nobita');
                ok -d $libdir;
            };

            it "shows errors if the specified perl does not exist." => sub {
                throws_ok {
                    ## perl-5.8.8 is not mock-installed
                    $app->{args} = [ "lib", "create", 'perl-5.8.8@nobita' ];
                    $app->run;
                } qr{^ERROR: 'perl-5.8.8' is not installed yet, 'perl-5.8.8\@nobita' cannot be created.\n};

                $libdir = dir($App::perlbrew::PERLBREW_HOME, "libs", 'perl-5.8.8@nobita');
                ok !-d $libdir;
            };
        };
    };

    describe "`delete` sub-command," => sub {
        before each => sub {
            File::Path::Tiny::mk(
                catdir($App::perlbrew::PERLBREW_HOME, "libs", 'perl-5.14.2@nobita')
            );
        };

        it "deletes the local::lib folder" => sub {
            stdout_is {
                my $app = App::perlbrew->new("lib", "delete", "nobita");
                $app->expects("current_perl")->returns("perl-5.14.2")->at_least_once;
                $app->run;
            } qq{lib 'perl-5.14.2\@nobita' is deleted.\n};

            ok !-d catdir($App::perlbrew::PERLBREW_HOME, "libs", 'perl-5.14.2@nobita');
            ok !-e catdir($App::perlbrew::PERLBREW_HOME, "libs", 'perl-5.14.2@nobita');
        };

        it "shows errors when the given lib does not exists " => sub {
            throws_ok {
                my $app = App::perlbrew->new("lib", "delete", "yoga");
                $app->expects("current_perl")->returns("perl-5.14.2")->at_least_once;
                $app->run;
            } qr{^ERROR: 'perl-5\.14\.2\@yoga' does not exist\.};
        };
    };
};

runtests unless caller;
