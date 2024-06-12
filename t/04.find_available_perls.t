#!/usr/bin/env perl
use Test2::V0;
use App::perlbrew;

plan 52;

my $html = <<HERE;
<!-- LATEST_RELEASES --> 
<table border="1">
<tr><th>Release</th><th>File</th><th>Type</th><th>Age</th></tr>
<tr><td>5.13</td><td>5.13.11</td><td><a href="perl-5.13.11.tar.gz">perl-5.13.11.tar.gz</a>, <a href="perl-5.13.11.tar.bz2">perl-5.13.11.tar.bz2</a></td><td>devel</td><td>14 days</td></tr>
<tr><td>5.12</td><td>5.12.3</td><td><a href="perl-5.12.3.tar.gz">perl-5.12.3.tar.gz</a>, <a href="perl-5.12.3.tar.bz2">perl-5.12.3.tar.bz2</a></td><td>maint</td><td>2 months, 11 days</td></tr>
<tr><td>5.10</td><td>5.10.1</td><td><a href="perl-5.10.1.tar.gz">perl-5.10.1.tar.gz</a>, <a href="perl-5.10.1.tar.bz2">perl-5.10.1.tar.bz2</a></td><td>maint</td><td>1 year, 7 months</td></tr>
<tr><td>5.8</td><td>5.8.9</td><td><a href="perl-5.8.9.tar.gz">perl-5.8.9.tar.gz</a>, <a href="perl-5.8.9.tar.bz2">perl-5.8.9.tar.bz2</a></td><td>maint</td><td>2 years, 3 months</td></tr>
<tr><td>5.6</td><td>5.6.2</td><td><a href="perl-5.6.2.tar.gz">perl-5.6.2.tar.gz</a></td><td>maint</td><td>7 years, 4 months</td></tr>
<tr><td>5.5</td><td>5.5.4</td><td><a href="perl5.005_04.tar.gz">perl5.005_04.tar.gz</a></td><td>maint</td><td>7 years, 1 month</td></tr>
<tr><td>5.4</td><td>5.4.5</td><td><a href="perl5.004_05.tar.gz">perl5.004_05.tar.gz</a></td><td>maint</td><td>11 years, 11 months</td></tr>
<tr><td>5.3</td><td>5.3.7</td><td><a href="perl5.003_07.tar.gz">perl5.003_07.tar.gz</a></td><td>maint</td><td>14 years, 5 months</td></tr>
</table>

<p><small>(A year is 365.2425 days and a month is 30.436875 days.)</small></p>
HERE

my @expected_releases = (
    {
        'file'    => 'perl-5.13.11.tar.gz',
        'type'    => 'devel',
        'release' => '5.13.11',
        'age'     => '14 days',
        'branch'  => '5.13'
    },
    {
        'file'    => 'perl-5.12.3.tar.gz',
        'type'    => 'maint',
        'release' => '5.12.3',
        'age'     => '2 months, 11 days',
        'branch'  => '5.12'
    },
    {
        'file'    => 'perl-5.10.1.tar.gz',
        'type'    => 'maint',
        'release' => '5.10.1',
        'age'     => '1 year, 7 months',
        'branch'  => '5.10'
    },
    {
        'file'    => 'perl-5.8.9.tar.gz',
        'type'    => 'maint',
        'release' => '5.8.9',
        'age'     => '2 years, 3 months',
        'branch'  => '5.8'
    },
    {
        'file'    => 'perl-5.6.2.tar.gz',
        'type'    => 'maint',
        'release' => '5.6.2',
        'age'     => '7 years, 4 months',
        'branch'  => '5.6'
    },
    {
        'file'    => 'perl5.005_04.tar.gz',
        'type'    => 'maint',
        'release' => '5.5.4',
        'age'     => '7 years, 1 month',
        'branch'  => '5.5'
    },
    {
        'file'    => 'perl5.004_05.tar.gz',
        'type'    => 'maint',
        'release' => '5.4.5',
        'age'     => '11 years, 11 months',
        'branch'  => '5.4'
    },
    {
        'file'    => 'perl5.003_07.tar.gz',
        'type'    => 'maint',
        'release' => '5.3.7',
        'age'     => '14 years, 5 months',
        'branch'  => '5.3'
    },
    {
        'file'    => 'perl5.003_07.tar.gz',
        'type'    => 'maint',
        'release' => '5.3.7',
        'age'     => '14 years, 5 months',
        'branch'  => '5.3'
    },
    {
        'file'    => 'perl5.003_07.tar.gz',
        'type'    => 'maint',
        'release' => '5.3.7',
        'age'     => '14 years, 5 months',
        'branch'  => '5.3'
    },
    {
        'file'    => 'perl5.003_07.tar.gz',
        'type'    => 'maint',
        'release' => '5.3.7',
        'age'     => '14 years, 5 months',
        'branch'  => '5.3'
    }
);
my $app = App::perlbrew->new();

my @releases = ();
for my $line ( split "\n", $html ) {
    $line =~
m|<tr><td>(.*)</td><td>(.*)</td><td><a href="(.*?)">.*<td>(.*)</td><td>(.*)</td>|;
    push @releases,
      { branch => $1, release => $2, file => $3, type => $4, age => $5 }
      if ( $1 && $2 && $3 && $4 && $5 );
}

is @releases              => 11,   'found 11 releases';
is $releases[0]->{branch} => 5.13, '5.13 branch';

#is $releases[0]->{release} => 5.13, '5.13 branch';

TEST:
for my $i ( 0 .. scalar @releases - 1 - 1 ) {
    is $releases[$i]->{branch} => $expected_releases[$i]->{branch}, "branch " . $releases[$i]->{branch} . " found";
    is $releases[$i]->{release} => $expected_releases[$i]->{release}, "release " . $releases[$i]->{release} . " found";
    is $releases[$i]->{file} => $expected_releases[$i]->{file}, "file " . $releases[$i]->{file} . " found";
    is $releases[$i]->{type} => $expected_releases[$i]->{type}, "type " . $releases[$i]->{type} . " found";
    is $releases[$i]->{age} => $expected_releases[$i]->{age}, "age " . $releases[$i]->{age} . " found";
}

