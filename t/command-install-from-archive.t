#!/usr/bin/env perl
use Test2::V0;
use Test2::Tools::Spec;

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require 'test2_helpers.pl';

sub arrange_file;
sub expect_dispatch_via;
sub should_install_from_archive;

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

done_testing;

sub should_install_from_archive {
    my ($title, %params) = @_;

    describe $title => sub {
        my %shared;

        before_each 'arrange file', sub {
            my $file = $shared{file} = arrange_file
                name => $params{filename},
                tempdir => 1,
                ;

            $shared{app} = App::perlbrew->new(install => "$file");
        };

        expect_dispatch_via
            shared => \%shared,
            method => 'do_install_archive',
            with_args => [ object { call 'basename' => $params{filename} } ];

        expect_dispatch_via
            shared => \%shared,
            method => 'do_extract_tarball',
            with_args => [ object { call 'basename' => $params{filename} } ],
            stubs     => { do_install_this => '' };

        expect_dispatch_via
            shared => \%shared,
            method => 'do_install_this',
            with_args => [
                object { call basename => 'foo' },
                $params{dist_version},
                $params{installation_name},
            ],
            stubs     => { do_extract_tarball => sub { $_[-1]->dirname->child('foo') } };

    };
};

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

sub expect_dispatch_via {
    my (%params) = @_;
    tests "should dispatch via $params{method}()" => sub {
        my $app = $params{shared}{app};
        my $mock = mocked($app);

        if ($params{stubs}) {
            $mock->stubs($params{stubs});
        }

        if ($params{with_args}) {
            $mock->expects($params{method})
                ->with(@{ $params{with_args} })
                ->returns(undef);
        } else {
            $mock->expects($params{method})
                ->returns(undef);
        }

        $app->run;

        $mock->verify;
        $mock->reset;
    };
}
