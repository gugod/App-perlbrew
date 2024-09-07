#!/usr/bin/env perl
use Test2::V0;
use Test2::Tools::Spec;
use File::Temp qw( tempdir );

use FindBin;
use lib $FindBin::Bin;

use App::perlbrew;
require "test2_helpers.pl";
use PerlbrewTestHelpers qw(read_file write_file);

mock_perlbrew_install("perl-5.36.1");

describe "App::perlbrew->make_shim()" => sub {
    it "should show usage", sub {
        mock_perlbrew_use("perl-5.36.1");

        my $called = 0;
        my $mock = mock 'App::perlbrew',
            override => [
                run_command_help => sub { $called++; "" }
            ];

        ok(
            lives {
                my $app = $mock->class->new("make-shim");
                $app->run;
            },
            "`make-shim` should not trigger any exceptions"
        ) or note($@);
        is $called, 1, "`help` command should be running.";
    };
};

describe "App::perlbrew->make_shim('foo')" => sub {
    it "should err when perlbrew is off" => sub {
        mock_perlbrew_off();

        my $dir = tempdir();
        chdir($dir);

        ok dies {
            my $app = App::perlbrew->new("make-shim", "foo");
            $app->run();
        }, qr(^ERROR:);

        ok ! -f "foo", "foo is not produced";
    };

    it "should err when 'foo' already exists" => sub {
        mock_perlbrew_use("perl-5.36.1");
        my $dir = tempdir();
        chdir($dir);
        write_file ("foo", "hello");

        ok dies {
            my $app = App::perlbrew->new("make-shim", "foo");
            $app->run();
        }, qr(^ERROR:);

        ok dies {
            my $app = App::perlbrew->new("make-shim", "-o", "foo", "bar");
           $app->run();
        }, qr(^ERROR:);
    };

    it "should produce 'foo' in the current dir" => sub {
        mock_perlbrew_use("perl-5.36.1");
        my $dir = tempdir();
        chdir($dir);

        my $app = App::perlbrew->new("make-shim", "foo");
        $app->run();

        ok -f "foo", "foo is produced under current directory.";
        my $shim_content = read_file("foo");
        diag "\nThe content of shim:\n----\n$shim_content\n----\n";
    };

    it "should produce 'foo' in the current dir" => sub {
        mock_perlbrew_use("perl-5.36.1");
        my $dir = tempdir();
        chdir($dir);

        my $app = App::perlbrew->new("make-shim", "-o", "foo", "bar");
        $app->run();

        ok -f "foo", "foo is produced under current directory.";
        my $shim_content = read_file("foo");
        diag "\nThe content of shim:\n----\n$shim_content\n----\n";
    };
};

done_testing;
