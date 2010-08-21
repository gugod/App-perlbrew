#!perl
use strict;
use Test::More tests => 12;

use App::perlbrew;

my $app = App::perlbrew->new('install', '-n', 'perl-5.12.1',
    '-Dusethreads', '-DDEBUGGING', '-Uusemymalloc', '-Accflags');
note explain($app);

is join(' ', $app->get_args), join(' ', qw(install perl-5.12.1));

is_deeply $app->{D}, [qw(usethreads DEBUGGING)], '-D';
is_deeply $app->{U}, [qw(usemymalloc)],          '-U';
is_deeply $app->{A}, [qw(ccflags)],              '-A';

ok $app->{quiet},  'quiet';
ok $app->{notest}, 'notest';


$app = App::perlbrew->new('install', '--no-quiet', 'perl-5.12.1',
    '-D', 'usethreads', '-D=DEBUGGING', '-U', 'usemymalloc', '-A', 'ccflags');
note explain($app);

is join(' ', $app->get_args), join(' ', qw(install perl-5.12.1));

is_deeply $app->{D}, [qw(usethreads DEBUGGING)], '-D';
is_deeply $app->{U}, [qw(usemymalloc)],          '-U';
is_deeply $app->{A}, [qw(ccflags)],              '-A';

ok !$app->{quiet},  'quiet';
ok !$app->{notest}, 'notest';

