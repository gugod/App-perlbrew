#!/usr/bin/env perl
use Test2::V0;
use Test2::Tools::Spec;
use File::Temp qw( tempdir );

$ENV{PERLBREW_ROOT} = my $perlbrew_root = tempdir( CLEANUP => 1 );
$ENV{PERLBREW_HOME} = my $perlbrew_home = tempdir( CLEANUP => 1 );

use App::perlbrew;

describe "App::perlbrew" => sub {
    it "should be able to run 'display-bashrc' command" => sub {
        my $app = App::perlbrew->new();
        ok $app->can("run_command_display_bashrc");
    };

    it "should be able to run 'display-cshrc' command" => sub {
        my $app = App::perlbrew->new();
        ok $app->can("run_command_display_cshrc");
    };
};

done_testing;
