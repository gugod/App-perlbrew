#!/usr/bin/env perl
use Test2::V0;
use Test2::Plugin::IOEvents;
use Test2::Tools::Spec;

BEGIN {
    delete $ENV{PERLBREW_HOME};
    delete $ENV{PERLBREW_ROOT};
    delete $ENV{PERLBREW_LIB};
}

use FindBin;
use lib $FindBin::Bin;

use App::perlbrew;
require "test2_helpers.pl";

use File::Spec::Functions qw( catdir );

mock_perlbrew_install("perl-5.12.3");
mock_perlbrew_install("perl-5.12.4");
mock_perlbrew_install("perl-5.14.1");
mock_perlbrew_install("perl-5.14.2");

{
    no warnings 'redefine';
    sub App::perlbrew::current_perl { "perl-5.12.3" }
}

describe "list command," => sub {
    describe "when there no libs under PERLBREW_HOME,", sub {
        it "displays a list of perl installation names", sub {
            my $app = App::perlbrew->new("list");
            my $events = intercept { $app->run() };
            like $events,
                [
                    {info => [{tag => 'STDOUT', details => qr/^(\s|\*)\sc?perl-?\d\.\d{1,3}[_.]\d{1,2}\s+/}]}
                ],
                'Cannot find Perl in output';
        };
    };

    describe "when there are lib under PERLBREW_HOME,", sub {
        before_each setup_dirs => sub {
            unless ( -d catdir($App::perlbrew::PERLBREW_HOME, "libs", 'perl-5.12.3@nobita') ) {
                App::perlbrew->new("lib", "create", "nobita")->run;
            }
            unless ( -d catdir($App::perlbrew::PERLBREW_HOME, "libs", 'perl-5.12.3@shizuka') ) {
                App::perlbrew->new("lib", "create", "shizuka")->run;
            }
        };

        it "displays lib names" => sub {
            my $app = App::perlbrew->new("list");
            my $events = intercept { $app->run() };
            like $events,
                [
                    {info => [{tag => 'STDOUT', details => qr/^(\s|\*)\sc?perl-?\d\.\d{1,3}[_.]\d{1,2}(@\w+)?/}]}
                ],
                'Cannot find Perl with libraries in output';
        };

        it "marks currently activated lib", sub {
            $ENV{PERLBREW_LIB} = "nobita";
            my $app = App::perlbrew->new("list");
            my $events = intercept { $app->run() };
            like $events,
                [
                    {info => [{tag => 'STDOUT', details => qr/^(\s|\*)\sc?perl-?\d\.\d{1,3}[_.]\d{1,2}(\@nobita)?/}]}
                ],
                'Cannot find Perl with libraries in output';
        };
        describe "when `--no-decoration` is given", sub {
            it "does not mark anything", sub {
                $ENV{PERLBREW_LIB} = "nobita";
                my $app;
                my $events = intercept {
                    $app = App::perlbrew->new("list", "--no-decoration");
                    $app->run();
                };
                like $events,
                    [
                        {info => [{tag => 'STDOUT', details => qr/^perl-?\d\.\d{1,3}[_.]\d{1,2}(@\w+)?/}]}
                    ],
                    'No decoration mark in the output';
                };
        };
    };

    describe "when `--no-decoration` is given", sub {
        my $app = App::perlbrew->new("list", "--no-decoration");
        my $events = intercept { $app->run() };
        like $events,
            [
                {info => [{tag => 'STDOUT', details => qr/^perl-?\d\.\d{1,3}[_.]\d{1,2}(@\w+)?/}]}
            ],
            'No decoration mark in the output';
    };
};

done_testing;
