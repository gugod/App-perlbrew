#!/usr/bin/env perl
use Test2::V0;
use Test2::Tools::Spec;

use FindBin;
use File::Temp qw(tempdir);

use lib $FindBin::Bin;
use App::perlbrew;
use App::Perlbrew::Patchperl qw(maybe_patchperl);
require "test2_helpers.pl";

describe "App::Perlbrew::Patchperl maybe_patchperl" => sub {
    local $App::perlbrew::PERLBREW_ROOT;
    local $ENV{PATH};

    before_each init => sub {
        # Since patchperl may exist in developer's environment,
        # we override PATH to make the probe fail not able to find patchperl.
        $App::perlbrew::PERLBREW_ROOT = tempdir();
        $ENV{PATH} = "/bin";
    };

    it "should return undef, when patchperl does not exist" => sub {
        my $app_root = App::perlbrew->new->root;
        my $patchperl = maybe_patchperl( $app_root );
        is $patchperl, U();
    };

    describe "When patchperl exist in PATH", sub {
        my $bin = tempdir();

        before_each "fake-install a patchperl under PATH" => sub {
            $ENV{PATH} = "/bin:$bin";
            fake_install_patchperl("$bin/patchperl");
        };

        it "should return just 'patchperl', when patchperl do not exist in PERLBREW_ROOT" => sub {
            my $app_root = App::perlbrew->new->root;
            my $patchperl = maybe_patchperl( $app_root );
            is $patchperl, string "patchperl";
        };

        describe "When patchperl also exists in PERLBREW_ROOT", sub {
            before_each "fake-install a patchperl under PERLBREW_ROOT" => sub {
                fake_install_patchperl_under_app_root();
            };

            it "should return the path of patchperl under app root", sub {
                my $app_root = App::perlbrew->new->root;
                my $patchperl = maybe_patchperl( $app_root );
                is $patchperl, string $app_root->bin("patchperl");
            };
        };
    };

    describe "When patchperl exist in PERLBREW_ROOT but not in PATH", sub {
        before_each "fake-install a patchperl under PERLBREW_ROOT" => sub {
            fake_install_patchperl_under_app_root();
        };

        it "should return the path of patchperl under app root", sub {
            my $app_root = App::perlbrew->new->root;
            my $patchperl = maybe_patchperl( $app_root );
            is $patchperl, string $app_root->bin("patchperl");
        };
    };

    describe "When patchperl exist in PERLBREW_ROOT but it is not an executable file", sub {
        before_each "put a non-exutable file named patchperl under PERLBREW_ROOT" => sub {
            my $app_root_bin = App::perlbrew->new->root->bin();
            $app_root_bin->mkpath;
            my $path = $app_root_bin->child("patchperl");
            open my $fh, ">", $path
                or die "Failed to open $path for writing";
            print $fh, "dummy\n";
            close $fh;
        };

        it "should return undef", sub {
            my $app_root = App::perlbrew->new->root;
            my $patchperl = maybe_patchperl( $app_root );
            is $patchperl, U();
        };
    };
};

done_testing;

sub fake_install_patchperl {
    my ($path) = @_;

    open my $fh, ">", $path
        or die "Failed to fake-install a patchperl to $path";
    print $fh, '#!/usr/bin/env perl\nperl "Fake patchperl version 1.00\n";';
    close $fh;
    chmod 0755, $path;

    diag "Fake-install a patchperl to $path";
}

sub fake_install_patchperl_under_app_root {
    my $app_root_bin = App::perlbrew->new->root->bin();
    $app_root_bin->mkpath;
    fake_install_patchperl( $app_root_bin->child("patchperl") );
}
