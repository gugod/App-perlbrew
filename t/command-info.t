#!/usr/bin/env perl
use strict;
use warnings;
use Test::Spec;
use Test::Output;
use Config;

use App::perlbrew;

describe "info command" => sub {
    it "should display info if under perlbrew perl" => sub {
        my $app = App::perlbrew->new("info");

        my $mock_perl = { mock => 'current_perl' };
        my $perl_path = $Config{perlpath};

        $app->expects("current_perl")->returns($mock_perl)->at_least_once();
        $app->expects("current_env")->returns('perl-5.8.9');
        $app->expects("current_perl_executable")->returns($perl_path)->at_least_once(); # actaully real perl path
        $app->expects("configure_args")->with($mock_perl)->returns('config_args_value');
        $app->expects("system_perl_shebang")->never;
        local $ENV{PERLBREW_ROOT} = 'perlbrew_root_value';
        local $ENV{PERLBREW_HOME} = 'perlbrew_home_value';
        local $ENV{PERLBREW_PATH} = 'perlbrew_path_value';
        local $ENV{PERLBREW_MANPATH} = 'perlbrew_manpath_value';

my $expected = <<"OUT";
Current perl:
  Name: perl-5.8.9
  Path: \Q$perl_path\E
  Config: config_args_value
  Compiled at: ... \\d{1,2} \\d{4} \\d{1,2}:\\d{2}:\\d{2}

perlbrew:
  version: \Q$App::perlbrew::VERSION\E
  ENV:
    PERLBREW_ROOT: perlbrew_root_value
    PERLBREW_HOME: perlbrew_home_value
    PERLBREW_PATH: perlbrew_path_value
    PERLBREW_MANPATH: perlbrew_manpath_value
OUT

        stdout_like sub {
            $app->run();
        }, qr/$expected/;
    };
    it "should display info if under system perl" => sub {
        my $app = App::perlbrew->new("info");

        $app->expects("current_perl")->returns('');
        $app->expects("current_env")->never;
        $app->expects("current_perl_executable")->never;
        $app->expects("configure_args")->never;
        $app->expects("system_perl_shebang")->returns("system_perl_shebang_value")->once;
        local $ENV{PERLBREW_ROOT} = 'perlbrew_root_value';
        local $ENV{PERLBREW_HOME} = 'perlbrew_home_value';
        local $ENV{PERLBREW_PATH} = 'perlbrew_path_value';
        local $ENV{PERLBREW_MANPATH} = 'perlbrew_manpath_value';

my $expected = <<"OUT";
Current perl:
Using system perl.
Shebang: system_perl_shebang_value

perlbrew:
  version: \Q$App::perlbrew::VERSION\E
  ENV:
    PERLBREW_ROOT: perlbrew_root_value
    PERLBREW_HOME: perlbrew_home_value
    PERLBREW_PATH: perlbrew_path_value
    PERLBREW_MANPATH: perlbrew_manpath_value
OUT

        stdout_like sub {
            $app->run();
        }, qr/$expected/;
    };
};


runtests unless caller;
