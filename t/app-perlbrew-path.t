#!/usr/bin/env perl

use strict;
use warnings;

use Test::Spec;
use Test::Exception;
use Test::Deep;

use App::Perlbrew::Path;

sub looks_like_perlbrew_path;

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
