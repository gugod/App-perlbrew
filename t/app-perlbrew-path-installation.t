#!/usr/bin/env perl
use Test2::V0;
use Test2::Tools::Spec;

use File::Temp qw[];

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
        describe "without parameters" => sub {
            it "should return Instalations object" => sub {
                local $ENV{HOME};
                my $path = arrange_root->perls;
                is $path, looks_like_perl_installations("~/.root/perls");
            };
        };

        describe "with one parameter" => sub {
            it "should return Installation object" => sub {
                local $ENV{HOME};
                my $path = arrange_root->perls('blead');
                is $path, looks_like_perl_installation("~/.root/perls/blead");
            };
        };

        describe "with multiple paramters" => sub {
            it "should return Path object" => sub {
                local $ENV{HOME};
                my $path = arrange_root->perls('blead', '.version');
                is $path, looks_like_path("~/.root/perls/blead/.version");
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

            is \@list, [
                looks_like_perl_installation("~/.root/perls/perl-1"),
                looks_like_perl_installation("~/.root/perls/perl-2"),
            ];
        };
    };
};

describe "App::Perlbrew::Path::Installation" => sub {
    describe "name()" => sub {
        it "should return installation name" => sub {
            local $ENV{HOME};
            my $installation = arrange_installation('foo-bar');
            is $installation->name, 'foo-bar';
        };

        it "should provide path to perl" => sub {
            local $ENV{HOME};
            my $perl = arrange_installation('foo-bar')->perl;
            is $perl->stringify_with_tilde, '~/.root/perls/foo-bar/bin/perl';
        };

        it "should provide path to version file" => sub {
            local $ENV{HOME};
            my $file = arrange_installation('foo-bar')->version_file;
            is $file->stringify_with_tilde, '~/.root/perls/foo-bar/.version';
        };
    };
};

done_testing;

sub looks_like_path {
    my ($path, @tests) = @_;

    my $method = $path =~ m/^~/
    ? 'stringify_with_tilde'
    : 'stringify'
    ;

    object {
        call $method => $path;
        prop isa => 'App::Perlbrew::Path';
    };
}

sub looks_like_perl_installation {
    looks_like_path(@_, object { prop isa => 'App::Perlbrew::Path::Installation' });
}

sub looks_like_perl_installations {
    looks_like_path(@_, object { prop isa => 'App::Perlbrew::Path::Installation' });
}

sub arrange_root {
    $ENV{HOME} ||= File::Temp::tempdir(CLEANUP => 1);
    App::Perlbrew::Path::Root->new($ENV{HOME}, '.root')->mkpath;
}

sub arrange_installation {
    my ($name) = @_;

    my $root = arrange_root;
    $root->perls($name)->mkpath;
}
