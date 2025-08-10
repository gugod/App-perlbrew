#!/usr/bin/env perl
use Test2::V0;
use App::Perlbrew::Util qw( prompt );

sub withUserInput {
    my ($str, $test, $verify) = @_;
    return sub {
        my $out = '';
        open my $stdin, '<', \$str;
        open my $stdout, '>', \$out;

        *STDIN = $stdin;
        *STDOUT = $stdout;

        my $ans = &{$test};
        $verify->($out, $ans);
    };
}

subtest "prompt", sub {
    subtest "default answer on LF",
        withUserInput "\n"
        => sub {
            prompt("Agree ? [y/N]", "N");
        }
        => sub {
            my ($out, $ans) = @_;
            is $out, "Agree ? [y/N]";
            is $ans, "N";
        };

    subtest "default answer on CRLF",
        withUserInput "\r\n"
        => sub {
            prompt("Agree ? [y/N]", "N");
        }
        => sub {
            my ($out, $ans) = @_;
            is $out, "Agree ? [y/N]";
            is $ans, "N";
        };


    subtest "whatever answer with LF",
        withUserInput "Y\n",
        => sub {
            prompt("Agree ? [y/N]", "N");
        }
        => sub {
            my ($out, $ans) = @_;
            is $out, "Agree ? [y/N]";
            is $ans, "Y";
        };

    subtest "whatever answer with CRLF",
        withUserInput "foo\r\n",
        => sub {
            prompt("Agree ? [y/N]", "N");
        }
        => sub {
            my ($out, $ans) = @_;
            is $out, "Agree ? [y/N]";
            is $ans, "foo";
        };
};

done_testing;
