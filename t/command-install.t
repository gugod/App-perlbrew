#!/usr/bin/env perl
use Test2::V0;
use Test2::Tools::Spec;

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require 'test2_helpers.pl';

describe "command install" => sub {
    it "should install exact perl version" => sub {
        my $app = App::perlbrew->new(install => 'perl-5.12.1');
        my $mock = mocked($app)->expects('do_install_release')->with('perl-5.12.1', '5.12.1');
        $app->run;
        $mock->verify;
    };

    it "should install exact cperl version" => sub {
        my $app = App::perlbrew->new(install => 'cperl-5.26.4');
        my $mock = mocked($app)->expects('do_install_release')->with('cperl-5.26.4', '5.26.4');
        $app->run;
        $mock->verify;
    };

    it "should install stable version of perl" => sub {
        my @versions_sorted_from_new_to_old = qw( perl-5.29.0 perl-5.14.2 perl-5.14.1 perl-5.12.3 perl-5.12.2 );

        my $app = App::perlbrew->new(install => 'perl-stable');

        my $mock = mocked($app);
        $mock->expects('available_perls')->returns(sub { @versions_sorted_from_new_to_old });
        $mock->expects('do_install_release')->with('perl-5.14.2', '5.14.2');

        $app->run;
        $mock->verify;
    };

    it "should install blead perl" => sub {
        my $app = App::perlbrew->new(install => 'perl-blead');

        my $mock = mocked($app);
        $mock->expects('do_install_release')->never;
        $mock->expects('do_install_blead')->exactly(1)->returns(sub { "dummy" });

        $app->run;
        $mock->verify;
    };

    it "should install git checkout" => sub {
        my $checkout = tempdir (CLEANUP => 1);
        dir ($checkout, '.git')->mkpath;

        my $app = App::perlbrew->new(install => $checkout);

        my $mock = mocked($app);
        $mock->expects('do_install_git')->with($checkout)->returns(sub { "dummy" });

        $app->run;
        $mock->verify;
    };

    it "should install from archive" => sub {
        my $checkout = tempdir (CLEANUP => 1);
        my $file = file ($checkout, 'archive.tar.gz')->stringify;
        open my $fh, '>', $file;
        close $fh;

        my $app = App::perlbrew->new(install => $file);

        my $mock = mocked($app)->expects('do_install_archive')->with($file)->returns(sub { "dummy" });

        $app->run;
        $mock->verify;
    };

    it "should install from uri" => sub {
        my $app = App::perlbrew->new(install => 'http://example.com/foo/bar');

        my $mock = mocked($app)->expects('do_install_url')->with('http://example.com/foo/bar')->returns(sub { "dummy" });

        $app->run;
        $mock->verify;
    };
};

done_testing;
