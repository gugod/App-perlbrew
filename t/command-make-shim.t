#!/usr/bin/env perl
use strict;
use warnings;
use Test::Spec;
use File::Temp qw( tempdir );

BEGIN {
    delete $ENV{PERLBREW_HOME};
    delete $ENV{PERLBREW_ROOT};
    delete $ENV{PERLBREW_LIB};
}

use FindBin;
use lib $FindBin::Bin;

use App::perlbrew;
require "test_helpers.pl";

mock_perlbrew_install("perl-5.36.1");
mock_perlbrew_use("perl-5.36.1");

describe "App::perlbrew->make_shim('foo')" => sub {
    it "should produce 'foo' in the current dir" => sub {
        my $dir = tempdir();
        chdir($dir);

        my $app = App::perlbrew->new("make-shim", "foo");
        $app->run();

        ok -f "foo", "foo is produced under current directory.";
        my $shim_content = io("foo")->slurp;
        diag "\nThe content of shim:\n----\n$shim_content\n----\n";
    };
};

runtests unless caller;
