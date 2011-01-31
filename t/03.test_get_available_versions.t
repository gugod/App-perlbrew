#!/usr/bin/env perl
use strict;
use warnings;
use lib qw(lib);
use English qw( -no_match_vars );
use Test::More;
use Test::MockObject::Extends;
use Data::Dumper;

use App::perlbrew;

my $app = App::perlbrew->new();
$app = Test::MockObject::Extends->new($app);

my $html = <<END_HTML;
<table border="1">
<tbody><tr><th></th><td>Release</td><td>File</td><td>Type</td><td>Age</td>
</tr><tr><td>5.13</td><td>5.13.6</td><td><a href="perl-5.13.6.tar.gz">perl-5.13.6.tar.gz</a>, <a href="perl-5.13.6.tar.bz2">perl-5.13.6.tar.bz2</a></td><td>devel</td><td>26 days</td></tr>
<tr><td>5.12</td><td>5.12.2</td><td><a href="perl-5.12.2.tar.gz">perl-5.12.2.tar.gz</a>, <a href="perl-5.12.2.tar.bz2">perl-5.12.2.tar.bz2</a></td><td>maint</td><td>2 months, 9 days</td></tr>
<tr><td>5.10</td><td>5.10.1</td><td><a href="perl-5.10.1.tar.gz">perl-5.10.1.tar.gz</a>, <a href="perl-5.10.1.tar.bz2">perl-5.10.1.tar.bz2</a></td><td>maint</td><td>1 year, 2 months</td></tr>
<tr><td>5.8</td><td>5.8.9</td><td><a href="perl-5.8.9.tar.gz">perl-5.8.9.tar.gz</a>, <a href="perl-5.8.9.tar.bz2">perl-5.8.9.tar.bz2</a></td><td>maint</td><td>1 year, 11 months</td></tr>
<tr><td>5.6</td><td>5.6.2</td><td><a href="perl-5.6.2.tar.gz">perl-5.6.2.tar.gz</a></td><td>maint</td><td>7 years, 2 days</td></tr>
<tr><td>5.5</td><td>5.5.4</td><td><a href="perl5.005_04.tar.gz">perl5.005_04.tar.gz</a></td><td>maint</td><td>6 years, 8 months</td></tr>
<tr><td>5.4</td><td>5.4.5</td><td><a href="perl5.004_05.tar.gz">perl5.004_05.tar.gz</a></td><td>maint</td><td>11 years, 6 months</td></tr>
<tr><td>5.3</td><td>5.3.7</td><td><a href="perl5.003_07.tar.gz">perl5.003_07.tar.gz</a></td><td>maint</td><td>14 years, 1 month</td></tr>
</tbody></table>
END_HTML

sub _mock_conf {
    my ($self) = shift;
    return {
        'mirror' => {
            'name' => 'North America, United States,Virginia, Dulles ' 
              . '(cpan-du.viaverio.com)',
            'url' => '&#104;&#116;&#116;&#112;://&#99;&#112;&#97;&#110;' 
              . '-&#100;&#117;.&#118;&#105;&#97;&#118;&#101;&#114;&#105;' 
              . '&#111;.&#99;&#111;&#109;/'
        }
    };
}

is scalar $app->get_available_perls(), 8, "Correct number of releases found";

my @known_perl_versions = (
    'perl-5.13.8', 'perl-5.12.2',  'perl-5.10.1',  'perl-5.8.9',
    'perl-5.6.2',  'perl5.005_04', 'perl5.004_05', 'perl5.003_07'
);

for my $perl_version ( $app->get_available_perls() ) {
    ok grep( $_ eq $perl_version, @known_perl_versions ), "$perl_version found";
}

$app->mock( 'conf', \&_mock_conf );

is scalar $app->get_available_perls(), 8, "Correct number of releases found";

done_testing();
