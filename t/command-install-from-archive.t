#!/usr/bin/env perl
use strict;
use warnings;

use Test::Spec 0.49; # with_deep
use Test::Deep;

use FindBin;
use lib $FindBin::Bin;

use App::perlbrew;

use Hash::Util;

require 'test_helpers.pl';

sub arrange_file;
sub arrange_available_perls;
sub arrange_command_line;
sub expect_dispatch_via;
sub should_install_from_archive;
sub is_path;

describe "command install <archive>" => sub {
	should_install_from_archive "with perl source archive" => (
		filename => 'perl-5.28.0.tar.gz',
		dist_version => '5.28.0',
		installation_name => 'perl-5.28.0',
	);

	should_install_from_archive "with perfixed perl source archive" => (
		filename => 'downloaded-perl-5.28.0.tar.gz',
		dist_version => '5.28.0',
		installation_name => 'perl-5.28.0',
	);

	should_install_from_archive "with cperl source archive" => (
		filename => 'cperl-5.28.0.tar.gz',
		dist_version => '5.28.0',
		installation_name => 'cperl-5.28.0',
	);

	should_install_from_archive "with prefixed cperl source archive" => (
		filename => 'downloaded-cperl-5.28.0.tar.gz',
		dist_version => '5.28.0',
		installation_name => 'cperl-5.28.0',
	);

};

runtests unless caller;

sub should_install_from_archive {
	my ($title, %params) = @_;

	Hash::Util::lock_keys %params,
		'filename',
		'dist_version',
		'installation_name',
		;

	context $title => sub {
		my $file;

		before each => sub {
			$file = arrange_file
				name => $params{filename},,
				tempdir => 1,
				;

			arrange_command_line install => $file;
		};

		expect_dispatch_via
			method => 'do_install_archive',
			with_args => [
				is_path (methods (basename => $params{filename}))
			];

		expect_dispatch_via method => 'do_extract_tarball',
			stubs     => { do_install_this => '' },
			with_args => [
				is_path (methods (basename => $params{filename}))
			];

		expect_dispatch_via method => 'do_install_this',
			stubs     => { do_extract_tarball => sub { $_[-1]->dirname->child ('foo') } },
			with_args => [
				is_path (methods (basename => 'foo')),
				$params{dist_version},
				$params{installation_name},
			];
	};
};

sub is_path {
	my (@tests) = @_;

	all (
		obj_isa ('App::Perlbrew::Path'),
		@tests,
	);
}

sub arrange_file {
	my (%params) = @_;

	my $dir;
	$dir ||= $params{dir} if $params{dir};
	$dir ||= tempdir (CLEANUP => 1) if $params{tempdir};
	$dir ||= '.';

	my $file = file ($dir, $params{name});

	open my $fh, '>', $file;
	close $fh;

	return $file;
}

sub arrange_command_line {
	my (@command_line) = @_;

	share my %shared;

	# Enforce stringification
	$shared{app} = App::perlbrew->new (map "$_", @command_line);
}

sub expect_dispatch_via {
	my (%params) = @_;

	it "should dispatch via $params{method}()" => sub {
		share my %shared;

		App::perlbrew->stubs (%{ $params{stubs} })
			if $params{stubs};

		my $expectation = App::perlbrew->expects ($params{method});
		$expectation = $expectation->with_deep (@{ $params{with_args} })
			if $params{with_args};

		$shared{app}->run;

		ok $expectation->verify;
	};
}

