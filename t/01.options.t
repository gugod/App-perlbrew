#!perl
use Test2::V0;
use Data::Dumper;

use App::perlbrew;

my $app = App::perlbrew->new('install', '-n', 'perl-5.12.1',
    '-Dusethreads', '-DDEBUGGING', '-Uusemymalloc', '-Accflags');

note Dumper($app);

is join(' ', $app->args), join(' ', qw(install perl-5.12.1));

is $app->{D}, [qw(usethreads DEBUGGING)], '-D';
is $app->{U}, [qw(usemymalloc)],          '-U';
is $app->{A}, [qw(ccflags)],              '-A';

ok !$app->{quiet},  'not quiet';
ok $app->{notest}, 'notest';

$app = App::perlbrew->new('install', '--quiet', 'perl-5.12.1',
    '-D', 'usethreads', '-D=DEBUGGING', '-U', 'usemymalloc', '-A', 'ccflags');

note Dumper($app);

is join(' ', $app->args), join(' ', qw(install perl-5.12.1));

is $app->{D}, [qw(usethreads DEBUGGING)], '-D';
is $app->{U}, [qw(usemymalloc)],          '-U';
is $app->{A}, [qw(ccflags)],              '-A';

ok $app->{quiet},  'quiet';
ok !$app->{notest}, 'notest';

done_testing;