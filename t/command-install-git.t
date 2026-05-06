#!/usr/bin/env perl
use Test2::V0;
use Test2::Tools::Spec;

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require 'test2_helpers.pl';

describe "do_install_git" => sub {
    # A real (but empty) git repo: 'git describe' will fail to produce
    # any output matching the v5.x.x pattern, exercising the new fallback logic.
    my $checkout;

    before_all 'create git checkout' => sub {
        $checkout = tempdir(CLEANUP => 1);
        system("git", "-C", $checkout, "init", "--quiet") == 0
            or die "Failed to create test git repo\n";
    };

    it "dies with a helpful message when git describe gives no matching version and --as is not given" => sub {
        my $app = App::perlbrew->new('install', $checkout);
        like(
            dies { $app->do_install_git($checkout) },
            qr/Unable to determine Perl version from 'git describe'/,
        );
    };

    it "calls do_install_this with version 'git' when git describe gives no matching version and --as is given" => sub {
        my $app = App::perlbrew->new('install', $checkout, '--as', 'my-dev-perl');

        my ($captured_version, $captured_name);
        my $mock = mocked($app);
        $mock->expects('do_install_this')->returns(sub {
            my ($self, $path, $version, $name) = @_;
            $captured_version = $version;
            $captured_name    = $name;
        });

        $app->do_install_git($checkout);
        $mock->verify;

        is $captured_version, 'git',      'dist_version is "git" so that usedevel is added to configure flags';
        is $captured_name,    'perl-git',  'installation_name passed to do_install_this is "perl-git"';
    };
};

done_testing;
