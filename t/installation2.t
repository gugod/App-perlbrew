#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
use Test::Exception;
require 'test_helpers.pl';

use Test::Spec;

## setup

##

note "PERLBREW_ROOT set to $ENV{PERLBREW_ROOT}";

describe "App::perlbrew" => sub {
    describe "->do_install_url method" => sub {
        it "should accept an URL to perl tarball, and download the tarball." => sub {
            my $app = App::perlbrew->new;

            my @expectations;
            push @expectations, App::perlbrew->expects("http_download")->returns(0);
            push @expectations, $app->expects("do_extract_tarball")->returns("");
            push @expectations, $app->expects("do_install_this")->returns("");

            $app->do_install_url("http://example.com/perl-5.14.0.tar.gz");

            for(@expectations) {
                ok $_->verify;
            }
            pass;
        }
    };

    describe "->do_install_archive method" => sub {
        it "accepts a path to perl tarball and perform installation process." => sub {
            my $app = App::perlbrew->new;

            my $e1 = $app->expects("do_extract_tarball")->returns("/a/fake/path/to/perl-5.12.3");
            my $e2 = $app->expects("do_install_this")->returns("");

            $app->do_install_archive("/a/fake/path/to/perl-5.12.3.tar.gz");

            ok $e1->verify, "do_extract_tarball is called";
            ok $e2->verify, "do_install_this is called";
            pass;
        }
    };
    
    describe "->do_install_this method" => sub {
        it "should log successful brews to the log_file." => sub {
            my $app = App::perlbrew->new;
            $app->{dist_extracted_dir} = '';
            $app->{dist_name} = '';
            
            my %expectations = (
                'do_system' => $app->expects("do_system")->returns(1),
            );
            
            $app->do_install_this('', '5.12.3', 'perl-5.12.3');
            open(my $log_handle, '<', $app->{log_file});
            like(<$log_handle>, qr/##### Brew Finished #####/, 'Success message shows in log');

            foreach my $sub_name (keys %expectations) {
                ok $expectations{$sub_name}->verify, "$sub_name is called";
            }
        };
        
        it "should log brew failure to the log_file if system call fails." => sub {
            my $app = App::perlbrew->new;
            $app->{dist_extracted_dir} = '';
            $app->{dist_name} = '';

            my %expectations = (
                'do_system' => $app->expects("do_system")->returns(0),
            );
            
            throws_ok( sub {$app->do_install_this('', '5.12.3', 'perl-5.12.3')}, qr/Installation process failed/);
            open(my $log_handle, '<', $app->{log_file});
            like(<$log_handle>, qr/##### Brew Failed #####/, 'Failure message shows in log');

            foreach my $sub_name (keys %expectations) {
                ok $expectations{$sub_name}->verify, "$sub_name is called";
            }
        };
    }

};

runtests unless caller;
