#!/usr/bin/env perl
use Test2::V0;
use Test2::Tools::Spec;
use Test2::Plugin::IOEvents;

use FindBin;
use lib $FindBin::Bin;

use App::perlbrew;
require "test2_helpers.pl";

mock_perlbrew_install("perl-5.14.1");
mock_perlbrew_install("perl-5.14.2");
mock_perlbrew_install("perl-5.14.3");

describe "lib command," => sub {
    describe "when invoked with unknown action name,", sub {
        it "should display error" => sub {
            my $x   = "correcthorsebatterystaple";
            my $app = App::perlbrew->new("lib", $x);
            my $events = intercept { $app->run() };
            like(
                $events,
                [
                    {info => [{tag => 'STDOUT', details => qr/Unknown command: $x/}]}
                ],
                'Unknown command'
            );
        }
    };

    describe "without lib name" => sub {
        it "create errs gracefully showing usage" => sub {
            my $app = App::perlbrew->new;
            like dies {
                $app->{args} = [ "lib", "create"];
                $app->run;
            }, qr/ERROR: /i, 'lib create';
        };
        it "delete errs gracefully showing usage" => sub {
            my $app = App::perlbrew->new;
            like dies {
                $app->{args} = [ "lib", "delete"];
                $app->run;
            }, qr/ERROR: /i, 'lib delete';
        };
    };

    describe "`create` sub-command," => sub {
        my ($app, $libdir);
        my $mock = mock "App::perlbrew";
        $mock->override("current_perl", sub { "perl-5.14.2" });

        before_each setup_path => sub {
            $app = $mock->class->new;
            $libdir = App::Perlbrew::Path->new($App::perlbrew::PERLBREW_HOME, "libs", 'perl-5.14.2@nobita');
        };

        after_each remove_path => sub {
            $libdir->rmpath;
        };

        describe "with a bare lib name," => sub {
            it "creates the lib folder for current perl" => sub {
                my $events = intercept {
                    $app->{args} = [ "lib", "create", "nobita" ];
                    $app->run;
                };
                like $events, [
                    {info => [{tag => 'STDOUT', details => qr{lib 'perl-5.14.2\@nobita' is created.}}]}
                ], 'stdout matches';

                ok -d $libdir, "libdir exists";
            };
        };

        describe "with \@ in the beginning of lib name," => sub {
            it "creates the lib folder for current perl" => sub {
                ok ! -d $libdir, "libdir do not exist";

                my $events = intercept {
                    $app->{args} = [ "lib", "create", '@nobita' ];
                    $app->run;
                };
                like $events, [
                    {info => [{tag => 'STDOUT', details => qr{lib 'perl-5.14.2\@nobita' is created.}}]}
                ], 'stdout matches';

                ok -d $libdir;
            }
        };

        describe "with perl name and \@  as part of lib name," => sub {
            it "creates the lib folder for the specified perl" => sub {
                my $events = intercept {
                    $app->{args} = [ "lib", "create", 'perl-5.14.2@nobita' ];
                    $app->run;
                };
                like $events, [
                    {info => [{tag => 'STDOUT', details => qr{lib 'perl-5.14.2\@nobita' is created.}}]}
                ], 'stdout matches';

                ok -d $libdir;
            };

            it "creates the lib folder for the specified perl" => sub {
                my $events = intercept {
                    $app->{args} = [ "lib", "create", 'perl-5.14.1@nobita' ];
                    $app->run;
                };
                like $events, [
                    {info => [{tag => 'STDOUT', details => qr{lib 'perl-5.14.1\@nobita' is created.}}]}
                ], 'stdout matches';

                $libdir = App::Perlbrew::Path->new($App::perlbrew::PERLBREW_HOME, "libs", 'perl-5.14.1@nobita');
                ok -d $libdir;
            };

            it "shows errors if the specified perl does not exist." => sub {
                like dies {
                    ## perl-5.8.8 is not mock-installed
                    $app->{args} = [ "lib", "create", 'perl-5.8.8@nobita' ];
                    $app->run;
                }, qr{^ERROR: 'perl-5.8.8' is not installed yet, 'perl-5.8.8\@nobita' cannot be created.\n},
                'dies with error message';

                $libdir = App::Perlbrew::Path->new($App::perlbrew::PERLBREW_HOME, "libs", 'perl-5.8.8@nobita');
                ok !-d $libdir;
            };
        };
    };

    describe "`delete` sub-command," => sub {
        my $nobita = App::Perlbrew::Path->new($App::perlbrew::PERLBREW_HOME, "libs", 'perl-5.14.2@nobita');
        before_each mkpath => sub {
            $nobita->mkpath;
        };
        after_each rmpath => sub {
            $nobita->rmpath;
        };

        it "deletes the local::lib folder" => sub {
            like intercept {
                my $mock = mock "App::perlbrew";
                $mock->override("current_perl", sub { "perl-5.14.2" });
                my $app = $mock->class->new("lib", "delete", "nobita");
                $app->run;
            }, [
                {info => [{tag => 'STDOUT', details => qr{lib 'perl-5.14.2\@nobita' is deleted.}}]}
            ], 'stdout matches';

            ok !-d App::Perlbrew::Path->new($App::perlbrew::PERLBREW_HOME, "libs", 'perl-5.14.2@nobita');
            ok !-e App::Perlbrew::Path->new($App::perlbrew::PERLBREW_HOME, "libs", 'perl-5.14.2@nobita');
        };

        it "shows errors when the given lib does not exists " => sub {
            like dies {
                my $mock = mock "App::perlbrew";
                $mock->override("current_perl", sub { "perl-5.14.2" });
                my $app = $mock->class->new("lib", "delete", "yoga");
                $app->run;
            }, qr{^ERROR: 'perl-5\.14\.2\@yoga' does not exist\.},
            'dies with error message';
        };
    };
};

done_testing;
