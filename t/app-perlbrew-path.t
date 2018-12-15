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

	describe "basename()" => sub {
		it "should return basename" => sub {
			my $path = App::Perlbrew::Path->new ("foo/bar/baz.tar.gz");

			is $path->basename, "baz.tar.gz";
		};

		it "should trim provided suffix match" => sub {
			my $path = App::Perlbrew::Path->new ("foo/bar/baz.tar.gz");

			is $path->basename (qr/\.tar\.(?:gz|bz2|xz)$/), "baz";
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

	describe "children()" => sub {
		it "should return empty list on empty match" => sub {
			my $root = arrange_testdir;

			cmp_deeply [ $root->children ], [];
		};

		it "should return Path instances" => sub {
			my $root = arrange_testdir;

			$root->child ($_)->mkpath for qw[ aa ab ba ];

			cmp_deeply [ $root->children ], [
				looks_like_perlbrew_path ($root->child ('aa')->stringify),
				looks_like_perlbrew_path ($root->child ('ab')->stringify),
				looks_like_perlbrew_path ($root->child ('ba')->stringify),
			];
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

	describe "readlink()" => sub {
		my $test_root;
		my $link;

		before each => sub {
			$test_root = arrange_testdir;
			$link = $test_root->child ('link');
		};

		context "when path doesn't exist" => sub {
			it "should return undef" => sub {
				is $link->readlink, undef;
			};
		};

		context "when path isn't a symlink" => sub {
			before each => sub { $link->mkpath };

			it "should return undef" => sub {
				is $link->readlink, undef;
			};
		};

		context "should return path object of link content" => sub {
			my $dest;

			before each => sub {
				$dest = $test_root->child ('dest');
				$dest->mkpath;
				symlink $dest, $link;
			};

			it "should return link path" => sub {
				my $read = $link->readlink;

				cmp_deeply $read, looks_like_perlbrew_path "$dest";
			};
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

	describe "stringify_with_tilde" => sub {
		it "should expand leading homedir" => sub {
			local $ENV{HOME} = "/home/perlbrew";
			my $path = App::Perlbrew::Path->new ("/home/perlbrew/.root");

			is $path->stringify_with_tilde, "~/.root";
		};

		it "should not expand leading homedir prefix" => sub {
			local $ENV{HOME} = "/home/perlbrew";
			my $path = App::Perlbrew::Path->new ("/home/perlbrew-stable/.root");

			is $path->stringify_with_tilde, "/home/perlbrew-stable/.root";
		};
	};

	describe "symlink()" => sub {
		it "should create symlink" => sub {
			my $root = arrange_testdir;
			my $file = $root->child ('file');

			open my $fh, '>>', $file or die $!;

			my $symlink = $file->symlink ($root->child ('symlink'));

			unless ($symlink) {
				fail;
				diag "Symlink failed: $!";
				return;
			}

			unless ($symlink eq $root->child ("symlink")) {
				fail;
				diag "is should return symlink object";
				diag "got     : $symlink";
				diag "expected: $root/symlink";
				return;
			}

			my $readlink = $symlink->readlink;

			unless ($readlink eq $file) {
				fail;
				diag "it should point to origin file";
				diag "got     : $readlink";
				diag "expected: $root/file";
				return;
			}

			pass;
		};

		it "should replace existing file in force mode" => sub {
			my $root = arrange_testdir;
			my $file = $root->child ('file');

			open my $fh, '>>', $file or die $!;

			$root->child ('foo')->symlink ($root->child ('symlink'))
				or diag "init failed: $!";

			my $symlink = $file->symlink ($root->child ('symlink'), 'force');

			unless ($symlink) {
				fail;
				diag "Symlink failed: $!";
				return;
			}

			unless ($symlink eq $root->child ("symlink")) {
				fail;
				diag "is should return symlink object";
				diag "got     : $symlink";
				diag "expected: $root/symlink";
				return;
			}

			my $readlink = $symlink->readlink;

			unless ($readlink eq $file) {
				fail;
				diag "it should point to origin file";
				diag "got     : $readlink";
				diag "expected: $root/file";
				return;
			}

			pass;
		};
	};

	describe "unlink()" => sub {
		it "should not report failure if file doesn't exist" => sub {
			my $root = arrange_testdir;
			my $file = $root->child ('file');

			$file->unlink;

			ok ! -e $file;
		};

		it "should remove file" => sub {
			my $root = arrange_testdir;
			my $file = $root->child ('file');

			open my $fh, '>>', $file or die $!;

			fail and diag ("file doesn't exist yet") and return
				unless -e $file;

			$file->unlink;

			ok ! -e $file;
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
