#!/usr/bin/env perl
use Test2::V0;
use Test2::Tools::Spec;

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require 'test2_helpers.pl';
use PerlbrewTestHelpers qw(stderr_is);

mock_perlbrew_install("perl-5.12.3");
mock_perlbrew_install("perl-5.12.4");
mock_perlbrew_install("perl-5.14.1");
mock_perlbrew_install("perl-5.14.2");

describe 'perlbrew exec perl -E "say 42"' => sub {
    it "invokes all perls" => sub {
        mocked(
            App::perlbrew->new(qw(exec perl -E), "say 42"),
            sub {
                my ($mock, $app) = @_;

                my @perls = $app->installed_perls;

                $mock->expects("do_system_with_exit_code")->exactly(4)->returns(
                    sub {
                        my ($self, @args) = @_;

                        is \@args, ["perl", "-E", "say 42"], "arguments";

                        my ($perlbrew_bin_path, $perlbrew_perl_bin_path, @paths) = split(":", $ENV{PATH});

                        my $perl_installation = shift @perls;

                        is $perlbrew_bin_path,      App::Perlbrew::Path->new($App::perlbrew::PERLBREW_ROOT, "bin")->stringify(), "perlbrew_bin_path";
                        is $perlbrew_perl_bin_path, App::Perlbrew::Path->new($App::perlbrew::PERLBREW_ROOT, "perls", $perl_installation->{name}, "bin")->stringify(), "perls/". $perl_installation->{name} . "/bin";

                        return 0;
                    }
                );

                $app->run;
            }
        );
    };
};

describe 'perlbrew exec --with perl-5.12.3 perl -E "say 42"' => sub {
    it "invokes perl-5.12.3/bin/perl" => sub {
        mocked(
            App::perlbrew->new(qw(exec --with perl-5.12.3 perl -E), "say 42"),
            sub {
                my ($mock, $app) = @_;

                $mock->expects("do_system_with_exit_code")->returns(
                    sub {
                        my ($self, @args) = @_;

                        is \@args, ["perl", "-E", "say 42"];

                        my ($perlbrew_bin_path, $perlbrew_perl_bin_path, @paths) = split(":", $ENV{PATH});

                        is $perlbrew_bin_path,      App::Perlbrew::Path->new($App::perlbrew::PERLBREW_ROOT, "bin")->stringify;
                        is $perlbrew_perl_bin_path, App::Perlbrew::Path->new($App::perlbrew::PERLBREW_ROOT, "perls", "perl-5.12.3", "bin")->stringify;

                        return 0;
                    }
                );

                $app->run;
            }
        );
    };
};

describe 'perlbrew exec --with perl-5.14.1,perl-5.12.3,perl-5.14.2 perl -E "say 42"' => sub {
    it "invokes each perl in the specified order" => sub {
        mocked(
            App::perlbrew->new(qw(exec --with), "perl-5.14.1 perl-5.12.3 perl-5.14.2", qw(perl -E), "say 42"),
            sub {
                my ($mock, $app) = @_;

                my @perl_paths;

                $mock->expects("do_system_with_exit_code")->exactly(3)->returns(
                    sub {
                        my ($self, @args) = @_;
                        my ($perlbrew_bin_path, $perlbrew_perl_bin_path, @paths) = split(":", $ENV{PATH});
                        push @perl_paths, $perlbrew_perl_bin_path;
                        return 0;
                    }
                );

                $app->run;

                is \@perl_paths, [
                    App::Perlbrew::Path->new($App::perlbrew::PERLBREW_ROOT, "perls", "perl-5.14.1", "bin")->stringify,
                    App::Perlbrew::Path->new($App::perlbrew::PERLBREW_ROOT, "perls", "perl-5.12.3", "bin")->stringify,
                    App::Perlbrew::Path->new($App::perlbrew::PERLBREW_ROOT, "perls", "perl-5.14.2", "bin")->stringify,
                ];
            }
        );
    };
};

describe 'perlbrew exec --with perl-5.14.1,perl-foobarbaz, ' => sub {
    it "ignore the unrecognized 'perl-foobarbaz'" => sub {
        mocked(
            App::perlbrew->new(qw(exec --with), "perl-5.14.1 perl-foobarbaz", qw(perl -E), "say 42"),
            sub {
                my ($mock, $app) = @_;

                my @perl_paths;

                $mock->expects("do_system_with_exit_code")->returns(
                    sub {
                        my ($self, @args) = @_;
                        my ($perlbrew_bin_path, $perlbrew_perl_bin_path, @paths) = split(":", $ENV{PATH});
                        push @perl_paths, $perlbrew_perl_bin_path;
                        return 0;
                    }
                );

                $app->run;

                is \@perl_paths, [
                    App::Perlbrew::Path->new($App::perlbrew::PERLBREW_ROOT, "perls", "perl-5.14.1", "bin")->stringify(),
                ];
            },
        )
    };
};

describe 'perlbrew exec --with perl-5.14.1,5.14.1 ' => sub {
    it "exec 5.14.1 twice, since that is what is specified" => sub {
        mocked(
            App::perlbrew->new(qw(exec --with), "perl-5.14.1 5.14.1", qw(perl -E), "say 42"),
            sub {
                my ($mock, $app) = @_;

                my @perl_paths;

                $mock->expects("do_system_with_exit_code")->exactly(2)->returns(
                    sub {
                        my ($self, @args) = @_;
                        my ($perlbrew_bin_path, $perlbrew_perl_bin_path, @paths) = split(":", $ENV{PATH});
                        push @perl_paths, $perlbrew_perl_bin_path;
                        return 0;
                    }
                );

                $app->run;

                is \@perl_paths, [
                    App::Perlbrew::Path->new($App::perlbrew::PERLBREW_ROOT, "perls", "perl-5.14.1", "bin")->stringify,
                    App::Perlbrew::Path->new($App::perlbrew::PERLBREW_ROOT, "perls", "perl-5.14.1", "bin")->stringify,
                ];
            }
        )
    };
};

describe 'exec exit code' => sub {
    describe "logging" => sub {
        it "should work" => sub {
            mocked(
                App::perlbrew->new(qw(exec --with), "perl-5.14.1", qw(perl -E), "somesub 42"),
                sub {
                    my ($mock, $app) = @_;

                    $mock->expects("format_info_output")->exactly(1)->returns("format_info_output_value\n");
                    $mock->expects("do_system_with_exit_code")->exactly(1)->returns(7<<8);

                    my $mock2 = mocked('App::perlbrew');
                    $mock2->expects("do_exit_with_error_code")->exactly(1)->returns(sub { die "simulate exit\n" });

                    stderr_is sub {
                        eval { $app->run; 1; };
                    }, <<"OUT";
Command [perl -E 'somesub 42'] terminated with exit code 7 (\$? = 1792) under the following perl environment:
format_info_output_value
OUT

                    $mock2->verify;
                }
            )
        };

        it "should be quiet if asked" => sub {
            my $app = App::perlbrew->new(qw(exec --quiet --with), "perl-5.14.1", qw(perl -E), "somesub 42");

            my $mock = mocked($app);
            $mock->expects("format_info_output")->exactly(0)->returns('should not be called!');
            $mock->expects("do_system_with_exit_code")->exactly(1)->returns(7<<8);

            my $mock2 = mocked('App::perlbrew');
            $mock2->expects("do_exit_with_error_code")->exactly(1)->returns(sub { die "simulate exit\n" });

            stderr_is sub {
                eval { $app->run; 1; };
            }, '';

            $mock->verify;
            $mock2->verify;
        };

        it "should format info output for right perl" => sub {
            my $app = App::perlbrew->new(qw(exec --with), "perl-5.14.1", qw(perl -E), "somesub 42");

            my $mock = mocked($app);
            $mock->expects("format_info_output")->exactly(1)->returns(sub {
                my ($self) = @_;
                is $self->current_env, 'perl-5.14.1';
                like $self->installed_perl_executable('perl-5.14.1'), qr/perl-5.14.1/;
                "format_info_output_value\n";
            });
            $mock->expects("do_system_with_exit_code")->exactly(1)->returns(7<<8);

            my $mock2 = mocked('App::perlbrew');
            $mock2->expects("do_exit_with_error_code")->exactly(1)->returns(sub {
                die "simulate exit\n";
            });

            eval { $app->run; 1; };

            $mock->verify;
            $mock2->verify;
        };
    };

    describe "no halt-on-error" => sub {
        it "should exit with success code when several perls ran" => sub {
            my $mock2 = mocked('App::perlbrew')->expects("do_exit_with_error_code")->never;

            mocked(
                App::perlbrew->new(qw(exec --with), "perl-5.14.1 perl-5.14.1", qw(perl -E), "say 42"),
                sub {
                    my ($mock, $app) = @_;
                    $mock->expects("do_system_with_exit_code")->exactly(2)->returns(0);
                    $app->run;
                }
            );

            $mock2->verify;
        };

        it "should exit with error code " => sub {
            my $app = App::perlbrew->new(qw(exec --with), "perl-5.14.1", qw(perl -E), "say 42");

            my $mock = mocked($app);
            $mock->expects("format_info_output")->exactly(1)->returns('');
            $mock->expects("do_system_with_exit_code")->exactly(1)->returns(3<<8);

            my $mock2 = mocked('App::perlbrew')->expects("do_exit_with_error_code")->exactly(1)->returns(sub {
                my ($self, $code) = @_;
                is $code, 1; # exit with error, but don't propogate exact failure codes
                die "simulate exit\n";
            });


            ok !eval { $app->run; 1; };
            is $@, "simulate exit\n";

            $mock->verify;
            $mock2->verify;
        };

        it "should exit with error code when several perls ran" => sub {
            my $app = App::perlbrew->new(qw(exec --with), "perl-5.14.1 perl-5.14.1", qw(perl -E), "say 42");

            my $mock = mocked($app);
            $mock->expects("format_info_output")->exactly(1)->returns('');
            my $calls = 0;
            $mock->expects("do_system_with_exit_code")->exactly(2)->returns(sub {
                $calls++;
                return 0 if ($calls == 2); # second exec call successed
                return 3<<8; # first exec failed
            });

            my $mock2 = mocked('App::perlbrew')->expects("do_exit_with_error_code")->exactly(1)->returns(sub {
                my ($self, $code) = @_;
                is $code, 1; # exit with error, but don't propogate exact failure codes
                die "simulate exit\n";
            });

            ok !eval { $app->run; 1; };
            is $@, "simulate exit\n";

            $mock->verify;
            $mock2->verify;
        };
    };

    describe "halt-on-error" => sub {
        it "should exit with success code " => sub {
            my $app = App::perlbrew->new(qw(exec --halt-on-error --with), "perl-5.14.1", qw(perl -E), "say 42");
            my $mock = mocked('App::perlbrew')->expects("do_exit_with_error_code")->never;
            my $mock2 = mocked($app)->expects("do_system_with_exit_code")->exactly(1)->returns(0);
            $app->run;
            $mock->verify;
            $mock2->verify;
        };

        it "should exit with error code " => sub {
            my $app = App::perlbrew->new(qw(exec --halt-on-error --with), "perl-5.14.1", qw(perl -E), "say 42");

            my $mock = mocked($app);
            $mock->expects("format_info_output")->exactly(1)->returns('');
            $mock->expects("do_system_with_exit_code")->exactly(1)->returns(3<<8);

            my $mock2 = mocked('App::perlbrew')->expects("do_exit_with_error_code")->exactly(1)->returns(sub {
                my ($self, $code) = @_;
                is $code, 3;
                die "simulate exit\n";
            });

            ok !eval { $app->run; 1; };
            is $@, "simulate exit\n";

            $mock->verify;
            $mock2->verify;
        };

        it "should exit with code 255 if program terminated with signal or something" => sub {
            my $app = App::perlbrew->new(qw(exec --halt-on-error --with), "perl-5.14.1", qw(perl -E), "say 42");

            my $mock = mocked($app);
            $mock->expects("format_info_output")->exactly(1)->returns('');
            $mock->expects("do_system_with_exit_code")->exactly(1)->returns(-1);

            my $mock2 = mocked('App::perlbrew')->expects("do_exit_with_error_code")->exactly(1)->returns(sub {
                my ($self, $code) = @_;
                is $code, 255;
                die "simulate exit\n";
            });

            ok !eval { $app->run; 1; };
            is $@, "simulate exit\n";

            $mock->verify;
            $mock2->verify;
        };

        it "should exit with error code when several perls ran" => sub {
            my $app = App::perlbrew->new(qw(exec --halt-on-error --with), "perl-5.14.1 perl-5.14.1", qw(perl -E), "say 42");

            my $mock = mocked($app);
            $mock->expects("format_info_output")->exactly(1)->returns('');
            my $calls = 0;
            $mock->expects("do_system_with_exit_code")->exactly(2)->returns(sub {
                $calls++;
                return 7<<8 if $calls == 2;
                return 0;
            });

            my $mock2 = mocked('App::perlbrew')->expects("do_exit_with_error_code")->exactly(1)->returns(sub {
                my ($self, $code) = @_;
                is $code, 7;
                die "simulate exit\n";
            });

            ok !eval { $app->run; 1; };
            is $@, "simulate exit\n";

            $mock->verify;
            $mock2->verify;
        };
    };
};

describe "minimal perl version" => sub {
    it "only executes the needed version" => sub {
        my @perl_paths;
        my $app = App::perlbrew->new(qw(exec --min 5.014), qw(perl -E), "say 42");

        my $mock = mocked($app)->expects("do_system_with_exit_code")->exactly(2)->returns(sub {
            my ($self, @args) = @_;
            my ($perlbrew_bin_path, $perlbrew_perl_bin_path, @paths) = split(":", $ENV{PATH});
            push @perl_paths, $perlbrew_perl_bin_path;
            return 0;
        });

        $app->run;

        # Don't care about the order, just the fact all of them were visited
        is [sort @perl_paths], [sort (
            App::Perlbrew::Path->new($App::perlbrew::PERLBREW_ROOT, "perls", "perl-5.14.2", "bin")->stringify(),
            App::Perlbrew::Path->new($App::perlbrew::PERLBREW_ROOT, "perls", "perl-5.14.1", "bin")->stringify(),
        )];

        $mock->verify;
    };
};

describe "maximum perl version" => sub {
    it "only executes the needed version" => sub {
        my @perl_paths;
        my $app = App::perlbrew->new(qw(exec --max 5.014), qw(perl -E), "say 42");

        my $mock = mocked($app)->expects("do_system_with_exit_code")->exactly(2)->returns(sub {
            my ($self, @args) = @_;
            my ($perlbrew_bin_path, $perlbrew_perl_bin_path, @paths) = split(":", $ENV{PATH});
            push @perl_paths, $perlbrew_perl_bin_path;
            return 0;
        });

        $app->run;

        # Don't care about the order, just the fact all of them were visited
        is [sort @perl_paths], [sort (
            App::Perlbrew::Path->new($App::perlbrew::PERLBREW_ROOT, "perls", "perl-5.12.4", "bin")->stringify(),
            App::Perlbrew::Path->new($App::perlbrew::PERLBREW_ROOT, "perls", "perl-5.12.3", "bin")->stringify(),
        )];

        $mock->verify;
    };
};

done_testing;
