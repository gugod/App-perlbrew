#!perl
use Test2::V0;

use App::perlbrew;
use File::Temp qw( tempdir );

$ENV{PERLBREW_ROOT} = $App::perlbrew::PERLBREW_ROOT = tempdir( CLEANUP => 1 );
$App::perlbrew::PERLBREW_HOME = tempdir( CLEANUP => 1 );

my $app = App::perlbrew->new;
diag join ", ", sort $app->commands;

subtest "exact result", sub {
    my @commands = $app->find_similar_commands( "install" );
    is 0+@commands, 1;
    is $commands[0], "install";
};

subtest "one result", sub {
    my @commands = $app->find_similar_commands( "instali" );
    is 0+@commands, 1;
    is $commands[0], "install";
};

subtest "two result", sub {
    my @commands = $app->find_similar_commands( "install-cpam" );
    is 0+@commands, 2;
    is $commands[0], "install-cpanm";
    is $commands[1], "install-cpm";
};

done_testing;
