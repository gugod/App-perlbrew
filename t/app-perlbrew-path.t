#!/usr/bin/env perl

use strict;
use warnings;

use File::Temp qw[];

use Test::Spec;
use Test::Exception;
use Test::Deep;

use App::Perlbrew::Path;

sub looks_like_perlbrew_path;
sub arrange_testdir;

describe "App::Perlbrew::Path" => sub {
	describe "new()" => sub {
		it "should accept one parameter" => sub {
			my $path = App::Perlbrew::Path->new ("foo/bar/baz");

			cmp_deeply $path, looks_like_perlbrew_path "foo/bar/baz";
		};

		it "should concatenate multiple parameters into single path" => sub {
			my $path = App::Perlbrew::Path->new ("foo", "bar/baz");

			cmp_deeply $path, looks_like_perlbrew_path "foo/bar/baz";
		};

		it "should die with undefined element" => sub {
			throws_ok
				{ App::Perlbrew::Path->new ('foo', undef, 'bar') }
				qr/^Received an undefined entry as a parameter/,
				'';
		};

		it "should concatenate long (root) path" => sub {
			my $path = App::Perlbrew::Path->new ('', qw(this is a long path to check if it is joined ok));

			cmp_deeply $path, looks_like_perlbrew_path '/this/is/a/long/path/to/check/if/it/is/joined/ok';
		};
	};

	describe "child()" => sub {
		it "should create direct child" => sub {
			my $path = App::Perlbrew::Path->new ("foo/bar")->child (1);

			cmp_deeply $path, looks_like_perlbrew_path "foo/bar/1";
		};

		it "should accept multiple children" => sub {
			my $path = App::Perlbrew::Path->new ("foo/bar")->child (1, 2);

			cmp_deeply $path, looks_like_perlbrew_path "foo/bar/1/2";
		};

		it "should return chainable object" => sub {
			my $path = App::Perlbrew::Path->new ("foo/bar")->child (1, 2)->child (3);

			cmp_deeply $path, looks_like_perlbrew_path "foo/bar/1/2/3";
		};
	};

	describe "mkpath()" => sub {
		it "should create recursive path" => sub {
			my $path = arrange_testdir ("foo/bar/baz");
			$path->mkpath;

			ok -d $path;
		};

		it "should not die when path already exists" => sub {
			my $path = arrange_testdir ("foo/bar/baz");

			$path->mkpath;

			lives_ok { $path->mkpath };
		};

		it "should return self" => sub {
			my $path = arrange_testdir ("foo/bar/baz");

			cmp_deeply $path->mkpath, looks_like_perlbrew_path "$path";
		};
	};

	describe "rmpath()" => sub {
		it "should remove path recursively" => sub {
			my $path = arrange_testdir ("foo");
			my $child = $path->child ("bar/baz");

			$child->mkpath;
			$path->rmpath;

			ok ! -d $path;
		};

		it "should not die when path doesn't exist" => sub {
			my $path = arrange_testdir ("foo");

			lives_ok { $path->rmpath };
		};

		it "should return self" => sub {
			my $path = arrange_testdir ("foo/bar/baz");

			cmp_deeply $path, looks_like_perlbrew_path "$path";
		};
	};

	return;
};

runtests unless caller;

sub looks_like_perlbrew_path {
	my ($expected) = @_;

	all (
		methods (stringify => $expected),
		obj_isa ('App::Perlbrew::Path'),
	);
}

sub arrange_testdir {
	my (@path) = @_;

	App::Perlbrew::Path->new (File::Temp::tempdir (CLEANUP => 1), @path);
}
