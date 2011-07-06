#!/usr/bin/env perl
use strict;
use warnings;
use lib qw(lib);
use Test::More;
use Path::Class;
use IO::All;
use File::Temp qw( tempdir );

my $tmpd = tempdir( CLEANUP => 1 );
$ENV{PERLBREW_ROOT} = $tmpd;
my $root = dir($tmpd);
require App::perlbrew;

my @perls = qw( yak needs shave );
my %exe = (
    # this enables "perlbrew exec perl -e '...'"
    perl => {
        content => qq[#!/bin/sh\nPERLBREW_TEST_PERL="\$0" exec perl "\$@";\n],
        # printing $^X won't work because these exe's are shell scripts that call the same perl
        args    => [ qw( exec perl -e ), 'open FH, ">>", shift and print FH "=$ENV{PERLBREW_TEST_PERL}\n" and close FH' ],
        output  => join('', sort map { "=$root/perls/$_/bin/perl\n" } @perls),
    },
    # also test an exe that isn't "perl" (like a script installed by a module)
    brewed_app => {
        content => qq[#!/bin/sh\necho \$0 >> \$1\n],
        args    => [ qw( exec brewed_app ) ],
        output  => join('', sort map { "$root/perls/$_/bin/brewed_app\n" } @perls),
    },
);

# build a fake root with some fake perls (most of this was modified from stuff found in t/installation.t)
foreach my $name ( @perls ) {
    my $bin = $root->subdir("perls", $name, "bin");
    App::perlbrew::mkpath($bin) for @perls;

    while ( my ($script, $data) = each %exe ) {
      next unless $data->{content};
      my $path = $bin->file($script);
      io($path)->print( $data->{content} );
      chmod 0755, $path;
    }
}

# exec each script
while ( my ($script, $data) = each %exe ) {
  # we need a file to which the subprocesses can append
  my $file = $root->file("test-exec-output.$script");

  my $app = App::perlbrew->new(@{ $data->{args} }, $file);
  $app->run;

  # $file should have output in it
  if ( -e $file ) {
    # get output from all execs (ensure same order as above)
    my $output = do { open(my $fh, '<', $file); join '', sort <$fh>; };
    is $output, $data->{output}, 'correct exec output';
  }
  else {
    ok 0, 'output file does not exist';
  }
}

done_testing;
