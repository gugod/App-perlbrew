#!/usr/bin/env perl
use Test2::V0;
use Test2::Tools::Spec;
use File::Spec;
use Config;

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require "test2_helpers.pl";
use PerlbrewTestHelpers qw(stdout_like);

describe "info command" => sub {
    it "should display info if under perlbrew perl" => sub {
        my $app = App::perlbrew->new("info");

        my $mock_perl = { mock => 'current_perl' };
        my $perl_path = $Config{perlpath};
        my $mock = mock $app,
            override => [
                current_perl => sub { $mock_perl },
                current_env => sub { 'perl-5.8.9' },
                installed_perl_executable => sub { $perl_path },
                configure_args => sub { 'config_args_value' },
                system_perl_shebang => sub { die }
            ];

        local $ENV{PERLBREW_ROOT} = 'perlbrew_root_value';
        local $ENV{PERLBREW_HOME} = 'perlbrew_home_value';
        local $ENV{PERLBREW_PATH} = 'perlbrew_path_value';
        local $ENV{PERLBREW_MANPATH} = 'perlbrew_manpath_value';

my $expected = <<"OUT";
Current perl:
  Name: perl-5.8.9
  Path: \Q$perl_path\E
  Config: config_args_value
  Compiled at: ...\\s+\\d{1,2}\\s+\\d{4}\\s+\\d{1,2}:\\d{2}:\\d{2}

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

        my $mock = mock $app,
            override => [
                current_perl => sub { '' },
                current_env => sub { die },
                installed_perl_executable => sub { die },
                configure_args => sub { die },
                system_perl_shebang => sub { "system_perl_shebang_value" },
            ];

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

    it "should display info for a module if the module is installed" => sub {
        my $app = App::perlbrew->new;

        my $mock_perl = { mock => 'current_perl' };
        my $perl_path = $Config{perlpath};
        my $module_name = "Data::Dumper";

        my $mock = mock $app,
            override => [
                "current_perl" => sub { $mock_perl },
                "current_env" => sub { 'perl-5.8.9'},
                "installed_perl_executable" => sub { $perl_path },
                "configure_args" => sub { 'config_args_value' },
                "system_perl_shebang" => sub { die },
            ];

        local $ENV{PERLBREW_ROOT} = 'perlbrew_root_value';
        local $ENV{PERLBREW_HOME} = 'perlbrew_home_value';
        local $ENV{PERLBREW_PATH} = 'perlbrew_path_value';
        local $ENV{PERLBREW_MANPATH} = 'perlbrew_manpath_value';

        my $v = "KNOWN_VALUE";
        (my $path_seperator = File::Spec->catdir( ( $v, $v ) ) ) =~ s/$v//g;
        my $module_location = join $path_seperator, split( /::/, $module_name);

my $expected = <<"OUT";
Current perl:
  Name: perl-5.8.9
  Path: \Q$perl_path\E
  Config: config_args_value
  Compiled at: ...\\s+\\d{1,2}\\s+\\d{4}\\s+\\d{1,2}:\\d{2}:\\d{2}

perlbrew:
  version: \Q$App::perlbrew::VERSION\E
  ENV:
    PERLBREW_ROOT: perlbrew_root_value
    PERLBREW_HOME: perlbrew_home_value
    PERLBREW_PATH: perlbrew_path_value
    PERLBREW_MANPATH: perlbrew_manpath_value

Module: \Q$module_name\E
  Location: .*\Q$module_location\E.pm
  Version: [\\d\\._]+
OUT

        stdout_like sub {
            $app->{args} = [ "info", $module_name];
            $app->run();
        }, qr/$expected/;
    };

    it "should display a message that the module can't be found if the module isn't installed" => sub {
        my $app = App::perlbrew->new;

        my $mock_perl = { mock => 'current_perl' };
        my $perl_path = $Config{perlpath};
        my $module_name = "SOME_FAKE_MODULE";

        my $mock = mock $app,
            override => [
                "current_perl" => sub { $mock_perl },
                "current_env" => sub { 'perl-5.8.9' },
                "installed_perl_executable" => sub { $perl_path },
                "configure_args" => sub { 'config_args_value' },
                "system_perl_shebang" => sub { die },
            ];

        local $ENV{PERLBREW_ROOT} = 'perlbrew_root_value';
        local $ENV{PERLBREW_HOME} = 'perlbrew_home_value';
        local $ENV{PERLBREW_PATH} = 'perlbrew_path_value';
        local $ENV{PERLBREW_MANPATH} = 'perlbrew_manpath_value';

my $expected = <<"OUT";
Current perl:
  Name: perl-5.8.9
  Path: \Q$perl_path\E
  Config: config_args_value
  Compiled at: ...\\s+\\d{1,2}\\s+\\d{4}\\s+\\d{1,2}:\\d{2}:\\d{2}

perlbrew:
  version: \Q$App::perlbrew::VERSION\E
  ENV:
    PERLBREW_ROOT: perlbrew_root_value
    PERLBREW_HOME: perlbrew_home_value
    PERLBREW_PATH: perlbrew_path_value
    PERLBREW_MANPATH: perlbrew_manpath_value

Module: $module_name could not be found, is it installed?.*
OUT

        stdout_like sub {
            $app->{args} = [ "info", $module_name];
            $app->run();
        }, qr/$expected/;
    };

};

done_testing;
