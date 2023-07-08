#!/usr/bin/env perl
use strict;
use warnings;
use Test::Spec;
use Test::Exception;
use File::Temp qw( tempdir );

use FindBin;
use lib $FindBin::Bin;

use App::perlbrew;
require "test_helpers.pl";

mock_perlbrew_install("perl-5.36.1");

describe "App::perlbrew->make_shim()" => sub {
    it "should show usage", sub {
        mock_perlbrew_use("perl-5.36.1");

        lives_ok {
            my $app = App::perlbrew->new("make-shim");
            $app->expects("run_command_help")->returns("")->at_least_once;
            $app->run;
        };
    };
};

describe "App::perlbrew->make_shim('foo')" => sub {
    it "should err when perlbrew is off" => sub {
        mock_perlbrew_off();

        my $dir = tempdir();
        chdir($dir);

        throws_ok {
            my $app = App::perlbrew->new("make-shim", "foo");
            $app->run();
        } qr(^ERROR:);

        ok ! -f "foo", "foo is not produced";
    };

    it "should err when 'foo' already exists" => sub {
        mock_perlbrew_use("perl-5.36.1");
        my $dir = tempdir();
        chdir($dir);
        io("foo")->print("hello");

        throws_ok {
            my $app = App::perlbrew->new("make-shim", "foo");
            $app->run();
        } qr(^ERROR:);

        throws_ok {
            my $app = App::perlbrew->new("make-shim", "-o", "foo", "bar");
           $app->run();
        } qr(^ERROR:);
    };

    it "should produce 'foo' in the current dir" => sub {
        mock_perlbrew_use("perl-5.36.1");
        my $dir = tempdir();
        chdir($dir);

        my $app = App::perlbrew->new("make-shim", "foo");
        $app->run();

        ok -f "foo", "foo is produced under current directory.";
        my $shim_content = io("foo")->slurp;
        diag "\nThe content of shim:\n----\n$shim_content\n----\n";
    };

    it "should produce 'foo' in the current dir" => sub {
        mock_perlbrew_use("perl-5.36.1");
        my $dir = tempdir();
        chdir($dir);

        my $app = App::perlbrew->new("make-shim", "-o", "foo", "bar");
        $app->run();

        ok -f "foo", "foo is produced under current directory.";
        my $shim_content = io("foo")->slurp;
        diag "\nThe content of shim:\n----\n$shim_content\n----\n";
    };
};

runtests unless caller;
