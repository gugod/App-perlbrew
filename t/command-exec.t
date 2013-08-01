#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require 'test_helpers.pl';

use Test::Spec;
use Test::Output;

mock_perlbrew_install("perl-5.12.3");
mock_perlbrew_install("perl-5.12.4");
mock_perlbrew_install("perl-5.14.1");
mock_perlbrew_install("perl-5.14.2");

describe 'perlbrew exec perl -E "say 42"' => sub {
    it "invokes all perls" => sub {
        my $app = App::perlbrew->new(qw(exec perl -E), "say 42");

        my @perls = $app->installed_perls;

        $app->expects("do_system_with_exit_code")->exactly(4)->returns(
            sub {
                my ($self, @args) = @_;

                is_deeply \@args, ["perl", "-E", "say 42"];

                my ($perlbrew_bin_path, $perlbrew_perl_bin_path, @paths) = split(":", $ENV{PATH});

                my $perl_installation = shift @perls;

                is $perlbrew_bin_path,      file($App::perlbrew::PERLBREW_ROOT, "bin");
                is $perlbrew_perl_bin_path, file($App::perlbrew::PERLBREW_ROOT, "perls", $perl_installation->{name}, "bin"), "perls/". $perl_installation->{name} . "/bin";

                return 0;
            }
        );

        $app->run;
    };
};

describe 'perlbrew exec --with perl-5.12.3 perl -E "say 42"' => sub {
    it "invokes perl-5.12.3/bin/perl" => sub {
        my $app = App::perlbrew->new(qw(exec --with perl-5.12.3 perl -E), "say 42");

        $app->expects("do_system_with_exit_code")->returns(
            sub {
                my ($self, @args) = @_;

                is_deeply \@args, ["perl", "-E", "say 42"];

                my ($perlbrew_bin_path, $perlbrew_perl_bin_path, @paths) = split(":", $ENV{PATH});

                is $perlbrew_bin_path,      file($App::perlbrew::PERLBREW_ROOT, "bin");
                is $perlbrew_perl_bin_path, file($App::perlbrew::PERLBREW_ROOT, "perls", "perl-5.12.3", "bin");

                return 0;
            }
        );

        $app->run;
    };
};

describe 'perlbrew exec --with perl-5.14.1,perl-5.12.3,perl-5.14.2 perl -E "say 42"' => sub {
    it "invokes each perl in the specified order" => sub {
        my $app = App::perlbrew->new(qw(exec --with), "perl-5.14.1 perl-5.12.3 perl-5.14.2", qw(perl -E), "say 42");

        my @perl_paths;
        $app->expects("do_system_with_exit_code")->exactly(3)->returns(
            sub {
                my ($self, @args) = @_;
                my ($perlbrew_bin_path, $perlbrew_perl_bin_path, @paths) = split(":", $ENV{PATH});
                push @perl_paths, $perlbrew_perl_bin_path;
                return 0;
            }
        );

        $app->run;

        is_deeply \@perl_paths, [
            file($App::perlbrew::PERLBREW_ROOT, "perls", "perl-5.14.1", "bin"),
            file($App::perlbrew::PERLBREW_ROOT, "perls", "perl-5.12.3", "bin"),
            file($App::perlbrew::PERLBREW_ROOT, "perls", "perl-5.14.2", "bin"),
        ];
    };
};

describe 'perlbrew exec --with perl-5.14.1,perl-foobarbaz, ' => sub {
    it "ignore the unrecognized 'perl-foobarbaz'" => sub {
        my $app = App::perlbrew->new(qw(exec --with), "perl-5.14.1 perl-foobarbaz", qw(perl -E), "say 42");

        my @perl_paths;
        $app->expects("do_system_with_exit_code")->returns(
            sub {
                my ($self, @args) = @_;
                my ($perlbrew_bin_path, $perlbrew_perl_bin_path, @paths) = split(":", $ENV{PATH});
                push @perl_paths, $perlbrew_perl_bin_path;
                return 0;
            }
        );

        $app->run;

        is_deeply \@perl_paths, [
            file($App::perlbrew::PERLBREW_ROOT, "perls", "perl-5.14.1", "bin"),
        ];
    };
};

describe 'perlbrew exec --with perl-5.14.1,5.14.1 ' => sub {
    it "exec 5.14.1 twice, since that is what is specified" => sub {
        my $app = App::perlbrew->new(qw(exec --with), "perl-5.14.1 5.14.1", qw(perl -E), "say 42");

        my @perl_paths;
        $app->expects("do_system_with_exit_code")->exactly(2)->returns(
            sub {
                my ($self, @args) = @_;
                my ($perlbrew_bin_path, $perlbrew_perl_bin_path, @paths) = split(":", $ENV{PATH});
                push @perl_paths, $perlbrew_perl_bin_path;
                return 0;
            }
        );

        $app->run;

        is_deeply \@perl_paths, [
            file($App::perlbrew::PERLBREW_ROOT, "perls", "perl-5.14.1", "bin"),
            file($App::perlbrew::PERLBREW_ROOT, "perls", "perl-5.14.1", "bin"),
        ];
    };
};

describe 'exec exit code' => sub {
    describe "logging" => sub {
        it "should work" => sub {
            my $app = App::perlbrew->new(qw(exec --with), "perl-5.14.1", qw(perl -E), "somesub 42");
            $app->expects("format_info_output")->exactly(1)->returns("format_info_output_value\n");
            App::perlbrew->expects("do_exit_with_error_code")->exactly(1)->returns(sub {
                die "simulate exit\n";
            });
            $app->expects("do_system_with_exit_code")->exactly(1)->returns(7<<8);
            stderr_is sub {
                eval { $app->run; 1; };
            }, <<"OUT";
Command [perl -E 'somesub 42'] terminated with exit code 7 (\$? = 1792) under the following perl environment:
format_info_output_value
OUT
        };
        it "should format info output for right perl" => sub {
            my $app = App::perlbrew->new(qw(exec --with), "perl-5.14.1", qw(perl -E), "somesub 42");
            $app->expects("format_info_output")->exactly(1)->returns(sub {
                my ($self) = @_;
                is $self->current_env, 'perl-5.14.1';
                like $self->current_perl_executable, qr/perl-5.14.1/;
                "format_info_output_value\n";
            });
            App::perlbrew->expects("do_exit_with_error_code")->exactly(1)->returns(sub {
                die "simulate exit\n";
            });
            $app->expects("do_system_with_exit_code")->exactly(1)->returns(7<<8);
            eval { $app->run; 1; };
        };
    };
    describe "no halt-on-error" => sub {
        it "should exit with success code when several perls ran" => sub {
            my $app = App::perlbrew->new(qw(exec --with), "perl-5.14.1 perl-5.14.1", qw(perl -E), "say 42");
            App::perlbrew->expects("do_exit_with_error_code")->never;
            $app->expects("do_system_with_exit_code")->exactly(2)->returns(0);
            $app->run;
        };
        it "should exit with error code " => sub {
            my $app = App::perlbrew->new(qw(exec --with), "perl-5.14.1", qw(perl -E), "say 42");
            $app->expects("format_info_output")->exactly(1)->returns('');
            App::perlbrew->expects("do_exit_with_error_code")->exactly(1)->returns(sub {
                my ($self, $code) = @_;
                is $code, 1; # exit with error, but don't propogate exact failure codes
                die "simulate exit\n";
            });
            $app->expects("do_system_with_exit_code")->exactly(1)->returns(3<<8);
            ok !eval { $app->run; 1; };
            is $@, "simulate exit\n";
        };
        it "should exit with error code when several perls ran" => sub {
            my $app = App::perlbrew->new(qw(exec --with), "perl-5.14.1 perl-5.14.1", qw(perl -E), "say 42");
            $app->expects("format_info_output")->exactly(1)->returns('');
            App::perlbrew->expects("do_exit_with_error_code")->exactly(1)->returns(sub {
                my ($self, $code) = @_;
                is $code, 1; # exit with error, but don't propogate exact failure codes
                die "simulate exit\n";
            });
            $app->expects("do_system_with_exit_code")->exactly(1)->returns(sub {
                $app->expects("do_system_with_exit_code")->exactly(1)->returns(sub { # make sure second call to exec is made
                    0; # second call is success
                });
                3<<8; # first exec failed
            });
            ok !eval { $app->run; 1; };
            is $@, "simulate exit\n";
        };
    };
    describe "halt-on-error" => sub {
        it "should exit with success code " => sub {
            my $app = App::perlbrew->new(qw(exec --halt-on-error --with), "perl-5.14.1", qw(perl -E), "say 42");
            App::perlbrew->expects("do_exit_with_error_code")->never;
            $app->expects("do_system_with_exit_code")->exactly(1)->returns(0);
            $app->run;
        };
        it "should exit with error code " => sub {
            my $app = App::perlbrew->new(qw(exec --halt-on-error --with), "perl-5.14.1", qw(perl -E), "say 42");
            $app->expects("format_info_output")->exactly(1)->returns('');
            App::perlbrew->expects("do_exit_with_error_code")->exactly(1)->returns(sub {
                my ($self, $code) = @_;
                is $code, 3;
                die "simulate exit\n";
            });
            $app->expects("do_system_with_exit_code")->exactly(1)->returns(3<<8);
            ok !eval { $app->run; 1; };
            is $@, "simulate exit\n";

        };
        it "should exit with code 255 if program terminated with signal or something" => sub {
            my $app = App::perlbrew->new(qw(exec --halt-on-error --with), "perl-5.14.1", qw(perl -E), "say 42");
            $app->expects("format_info_output")->exactly(1)->returns('');
            App::perlbrew->expects("do_exit_with_error_code")->exactly(1)->returns(sub {
                my ($self, $code) = @_;
                is $code, 255;
                die "simulate exit\n";
            });
            $app->expects("do_system_with_exit_code")->exactly(1)->returns(-1);
            ok !eval { $app->run; 1; };
            is $@, "simulate exit\n";

        };
        it "should exit with error code when several perls ran" => sub {
            my $app = App::perlbrew->new(qw(exec --halt-on-error --with), "perl-5.14.1 perl-5.14.1", qw(perl -E), "say 42");
            $app->expects("format_info_output")->exactly(1)->returns('');
            App::perlbrew->expects("do_exit_with_error_code")->exactly(1)->returns(sub {
                my ($self, $code) = @_;
                is $code, 7;
                die "simulate exit\n";
            });
            $app->expects("do_system_with_exit_code")->exactly(1)->returns(sub {
                $app->expects("do_system_with_exit_code")->exactly(1)->returns(sub {
                    7<<8;
                });
                0;
            });
            ok !eval { $app->run; 1; };
            is $@, "simulate exit\n";
        };
    };
};




runtests unless caller;
