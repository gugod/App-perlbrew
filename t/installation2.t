#!/usr/bin/env perl
use Test2::V0;
use Test2::Tools::Spec;

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require 'test2_helpers.pl';

## setup

##

note "PERLBREW_ROOT set to $ENV{PERLBREW_ROOT}";

subtest "App::perlbrew" => sub {
    subtest "->do_install_url method" => sub {
        subtest "it should accept an URL to perl tarball, and download the tarball." => sub {
            my $mock = Test2::Mock->new(class => "App::perlbrew");
            $mock->track(1);
            $mock->override("http_download", sub { 0 });
            $mock->override("do_extract_tarball", sub { "" });
            $mock->override("do_install_this", sub { "" });

            my $app = App::perlbrew->new;

            $app->do_install_url("http://example.com/perl-5.14.0.tar.gz");

            my $result = $mock->sub_tracking;
            ok $result->{http_download}, "http_download is called";
            ok $result->{do_extract_tarball}, "do_extract_tarball is called";
            ok $result->{do_install_this}, "do_install_this is called";
        }
    };

    subtest "->do_install_archive method" => sub {
        subtest "it accepts a path to perl tarball and perform installation process." => sub {
            my $mock = Test2::Mock->new(class => "App::perlbrew");
            $mock->track(1);
            $mock->override("do_extract_tarball", sub { App::Perlbrew::Path->new("/a/fake/path/to/perl-5.12.3")});
            $mock->override("do_install_this", sub { "" });
            my $app = App::perlbrew->new;

            $app->do_install_archive(App::Perlbrew::Path->new ("/a/fake/path/to/perl-5.12.3.tar.gz"));

            my $result = $mock->sub_tracking;
            ok $result->{do_extract_tarball}, "do_extract_tarball is called";
            ok $result->{do_install_this}, "do_install_this is called";
        }
    };

    subtest "->do_install_this method" => sub {
        subtest "it should log successful brews to the log_file." => sub {
            my $mock = Test2::Mock->new(class => "App::perlbrew");
            $mock->track(1);
            $mock->override("do_system", sub { 1 });

            my $app = App::perlbrew->new;
            $app->{dist_extracted_dir} = '';
            $app->{dist_name} = '';

            $app->do_install_this('', '5.12.3', 'perl-5.12.3');
            open(my $log_handle, '<', $app->{log_file});
            like(<$log_handle>, qr/##### Brew Finished #####/, 'Success message shows in log');

            my $result = $mock->sub_tracking;
            ok $result->{do_system}, "do_system is called";
        };

        subtest "it should log brew failure to the log_file if system call fails." => sub {
            my $mock = Test2::Mock->new(class => "App::perlbrew");
            $mock->track(1);
            $mock->override("do_system", sub { 0 });

            my $app = App::perlbrew->new;
            $app->{dist_extracted_dir} = '';
            $app->{dist_name} = '';

            like(
                dies {
                    $app->do_install_this('', '5.12.3', 'perl-5.12.3');
                },
                qr/Installation process failed/,
            );
            open(my $log_handle, '<', $app->{log_file});
            like(<$log_handle>, qr/##### Brew Failed #####/, 'Failure message shows in log');

            my $result = $mock->sub_tracking;
            ok $result->{do_system}, "do_system is called";
        };
    };

};

done_testing;
