#!/usr/bin/env perl
use strict;
use warnings;

use Test::Spec 0.49; # with_deep
use Test::Deep;

use FindBin;
use lib $FindBin::Bin;

use App::perlbrew;

require 'test_helpers.pl';

sub arrange_available_perls;
sub arrange_command_line;
sub expect_dispatch_via;

describe "command install" => sub {
	it "should install exact perl version" => sub {
        arrange_command_line install => 'perl-5.12.1';

		expect_dispatch_via do_install_release => [ 'perl-5.12.1', '5.12.1' ];
	};

	it "should install exact cperl version" => sub {
        arrange_command_line install => 'cperl-5.26.4';

		expect_dispatch_via do_install_release => [ 'cperl-5.26.4', '5.26.4' ];
	};

	it "should install stable version of perl" => sub {
        arrange_command_line install => 'perl-stable';

		arrange_available_perls qw[
			perl-5.12.2
			perl-5.12.3
			perl-5.14.1
			perl-5.14.2
			perl-5.29.0
		];

		expect_dispatch_via do_install_release => [ 'perl-5.14.2', '5.14.2' ];
	};

	it "should install blead perl" => sub {
        arrange_command_line install => 'perl-blead';
		expect_dispatch_via do_install_blead => [];
	};

	it "should install git checkout" => sub {
		my $checkout = tempdir (CLEANUP => 1);
		dir ($checkout, '.git')->mkpath;

        arrange_command_line install => $checkout;

		expect_dispatch_via do_install_git => [ $checkout ];
	};

	it "should install from archive" => sub {
		my $checkout = tempdir (CLEANUP => 1);
		my $file = file ($checkout, 'archive.tar.gz')->stringify;

		open my $fh, '>', $file;
		close $fh;

        arrange_command_line install => $file;

		expect_dispatch_via do_install_archive => [ all (
			obj_isa ('App::Perlbrew::Path'),
			methods (stringify => $file),
		) ];
	};

	it "should install from uri" => sub {
        arrange_command_line install => 'http://example.com/foo/bar';

		expect_dispatch_via do_install_url => [ 'http://example.com/foo/bar' ];
	};
};

runtests unless caller;

sub arrange_available_perls {
	my (@list) = @_;

	App::perlbrew->stubs (available_perls => sub { $_[0]->sort_perl_versions (@list) });
}

sub arrange_command_line {
	my (@command_line) = @_;

	share my %shared;

	$shared{app} = App::perlbrew->new (@command_line);
}

sub expect_dispatch_via {
	my ($method, $arguments) = @_;

	share my %shared;

	my $expectation = App::perlbrew->expects ($method);
	$expectation = $expectation->with_deep (@$arguments)
		if $arguments;


	$shared{app}->run;

	ok $expectation->verify;
}
