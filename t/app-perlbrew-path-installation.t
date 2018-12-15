#!/usr/bin/env perl

use strict;
use warnings;

use File::Temp qw[];

use Test::Spec;
use Test::Deep;

use App::Perlbrew::Path::Root;
use App::Perlbrew::Path::Installation;
use App::Perlbrew::Path::Installations;

sub looks_like_path;;
sub looks_like_perl_installation;
sub looks_like_perl_installations;
sub arrange_root;
sub arrange_installation;

describe "App::Perlbrew::Path::Root" => sub {
	describe "perls()" => sub {
		context "without parameters" => sub {
			it "should return Instalations object" => sub {
				local $ENV{HOME};
				my $path = arrange_root->perls;

				cmp_deeply $path, looks_like_perl_installations ("~/.root/perls");
			};
		};

		context "with one parameter" => sub {
			it "should return Installation object" => sub {
				local $ENV{HOME};
				my $path = arrange_root->perls ('blead');

				cmp_deeply $path, looks_like_perl_installation ("~/.root/perls/blead");
			};
		};

		context "with multiple paramters" => sub {
			it "should return Path object" => sub {
				local $ENV{HOME};
				my $path = arrange_root->perls ('blead', '.version');

				cmp_deeply $path, looks_like_path ("~/.root/perls/blead/.version");
			};
		}
	};
};

describe "App::Perlbrew::Path::Installations" => sub {
	describe "list()" => sub {
		it "should list known installations" => sub {
			local $ENV{HOME};
			my $root = arrange_root;
			arrange_installation 'perl-1';
			arrange_installation 'perl-2';

			my @list = $root->perls->list;

			cmp_deeply \@list, [
				looks_like_perl_installation ("~/.root/perls/perl-1"),
				looks_like_perl_installation ("~/.root/perls/perl-2"),
			];
		};
	};
};

describe "App::Perlbrew::Path::Installation" => sub {
	describe "name()" => sub {
		it "should return installation name" => sub {
			local $ENV{HOME};
			my $installation = arrange_installation ('foo-bar');

			cmp_deeply $installation->name, 'foo-bar';
		};

		it "should provide path to perl" => sub {
			local $ENV{HOME};
			my $perl = arrange_installation ('foo-bar')->perl;

			cmp_deeply $perl->stringify_with_tilde, '~/.root/perls/foo-bar/bin/perl';
		};

		it "should provide path to version file" => sub {
			local $ENV{HOME};
			my $file = arrange_installation ('foo-bar')->version_file;

			cmp_deeply $file->stringify_with_tilde, '~/.root/perls/foo-bar/.version';
		};
	};
};

runtests unless caller;

sub looks_like_path {
	my ($path, @tests) = @_;

	my $method = $path =~ m/^~/
		? 'stringify_with_tilde'
		: 'stringify'
		;

	all (
		methods ($method => $path),
		Isa ('App::Perlbrew::Path'),
		@tests,
	);
}

sub looks_like_perl_installation {
	looks_like_path (@_, Isa ('App::Perlbrew::Path::Installation'));
}

sub looks_like_perl_installations {
	looks_like_path (@_, Isa ('App::Perlbrew::Path::Installations'));
}

sub arrange_root {
	$ENV{HOME} ||= File::Temp::tempdir (CLEANUP => 1);
	App::Perlbrew::Path::Root->new ($ENV{HOME}, '.root')->mkpath;
}

sub arrange_installation {
	my ($name) = @_;

	my $root = arrange_root;
	$root->perls ($name)->mkpath;
}
