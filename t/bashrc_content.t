#!/usr/bin/env perl
use Test2::V0;
use Test2::Tools::Spec;

use App::perlbrew;

local $App::perlbrew::PERLBREW_ROOT;
local %ENV;

sub describe_bashrc_content;

describe "App::perlbrew->BASHRC_CONTENT()" => sub {
    describe "should not export custom PERLBREW_ROOT" => sub {
        describe_bashrc_content "with default settings" => (
        );

        describe_bashrc_content "when set only via global variable" => (
            PERLBREW_ROOT => 'perlbrew/root',
        );
    };

    describe "should export custom PERLBREW_ROOT" => sub {
        describe_bashrc_content "when env variable PERLBREW_ROOT is set" => (
            ENV_PERLBREW_ROOT => 'env/root',
            should_match => 'env/root',
        );

        describe_bashrc_content "when provided via argument" => (
            args => [qw[ --root arg/root ]],
            should_match => "arg/root",
        );

        describe_bashrc_content "when provided via argument (favor over env)" => (
            args => [qw[ --root arg/root ]],
            ENV_PERLBREW_ROOT => 'env/root',
            should_match => "arg/root",
        );
    };
};

done_testing;

sub describe_bashrc_content {
    my ($title, %params) = @_;

    it $title => sub {
        local %ENV = (
            HOME => 'default/home',
            (PERLBREW_ROOT => $params{ENV_PERLBREW_ROOT}) x!! exists $params{ENV_PERLBREW_ROOT},
        );
        local $App::perlbrew::PERLBREW_ROOT = $params{PERLBREW_ROOT} || $ENV{PERLBREW_ROOT};

        my $app = App::perlbrew->new (@{ $params{args} || [] });

        return ok $app->BASHRC_CONTENT =~ m{^export PERLBREW_ROOT=\Q$params{should_match}\E}m
        if $params{should_match};

        return ok $app->BASHRC_CONTENT !~ m{^export PERLBREW_ROOT=}m;
    };
}

