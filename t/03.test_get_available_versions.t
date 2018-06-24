#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use App::perlbrew;

{
    no warnings 'redefine';

    my $html_cpan     = read_cpan_html();
    my $html_metacpan = read_metacpan_html();

    sub App::perlbrew::http_get {
        my $url = shift;

        if ($url =~ m/www\.cpan\.org/) {
            return $html_cpan;
        } elsif ($url =~ m/fastapi\.metacpan\.org/) {
            return $html_metacpan;
        } else {
            return '';
        }
    }
}

plan tests => 13;

my $app = App::perlbrew->new();
my @vers = $app->available_perls();
is scalar( @vers ), 12, "Correct number of releases found";

my @known_perl_versions = (
    'perl-5.28.0',  'perl-5.26.2',  'perl-5.24.4',  'perl-5.22.3',
    'perl-5.13.11', 'perl-5.12.3',  'perl-5.10.1',  'perl-5.8.9',
    'perl-5.6.2',   'perl5.005_04', 'perl5.004_05', 'perl5.003_07'
);

for my $perl_version ( $app->available_perls() ) {
    ok grep( $_ eq $perl_version, @known_perl_versions ), "$perl_version found";
}

sub read_cpan_html {
    return <<'EOF';
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Perl Source - www.cpan.org</title>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />    <link rel="author" href="mailto:cpan+linkrelauthor@perl.org" />
	<link rel="canonical" href="http://www.cpan.org/src/index.html" />
	<link type="text/css" rel="stylesheet" href="../misc/css/cpan.css" />

</head>
<body class="section_source">

<table id="wrapper" border="0" width="95%" cellspacing="0" cellpadding="2" align="center">
    <tr>
        <td id="header">

			<div id="header_left">
				<a href="../index.html"><img src="../misc/images/cpan.png" id="logo" alt="CPAN" /></a>
     		</div>

			<div id="header_right">
			  <h1>Comprehensive Perl Archive Network</h1>
              <p id="strapline">Stop reinventing wheels, start building space rockets


</p>
           </div>
        </td>
    </tr>
    <tr>
        <td id="menubar_holder">

            <ul class="menubar">
				<li><a href="../index.html">Home</a></li>
                <li><a href="../modules/index.html">Modules</a></li>
                <li><a href="../ports/index.html">Ports</a></li>
                <li><a href="../src/README.html">Perl Source</a></li>
                <li><a href="../misc/cpan-faq.html">FAQ</a></li>
                <li><a href="../SITES.html">Mirrors</a></li>
			</ul>

			<div id="searchbar">
				<form method="get" action="http://search.cpan.org/search" name="f" class="searchbox menubar" id="f">
					<input type="hidden" name="mode" value="all" />
				<a href="http://search.cpan.org">Search</a>:
					 <input id="searchfield" type="text" name="query" value="" placeholder="Module name" />
					<input type="submit" value="Search" />
				</form>
			</div>
		</td>
    </tr>
    <tr>
        <td>
            <div id="content">



<h1>Perl Source</h1>

<p>
    Perl <a href="http://en.wikipedia.org/wiki/Compiler">compiles</a> on over <a href=
    "http://perldoc.perl.org/perlport.html#PLATFORMS">100 platforms</a>, if you
    want to install from a binary instead see the <a href=
    "../ports/index.html">ports</a> page (especially for Windows).
</p>


<h2>
    How to install from source
</h2>


<pre>
     wget <a href="http://www.cpan.org/src/perl-5.12.3.tar.gz">http://www.cpan.org/src/perl-5.12.3.tar.gz</a>
     tar -xzf perl-5.12.3.tar.gz
     cd perl-5.12.3
     ./Configure -des -Dprefix=$HOME/localperl
     make
     make test
     make install
</pre>
<p>
    Read both INSTALL and README.<strong>yoursystem</strong> in
    the <code>perl-5.12.3</code> directory for more detailed information.
</p>





<h2>Latest releases in each branch of Perl</h2>


<table class="os_version">
    <tr class="table_header">
        <th>Major</th>
        <th>Version</th>
        <th>Type</th>
        <th>Released</th>
        <th>Download</th>
    </tr>


    <tr >
        <td>5.13</td>
        <td>5.13.11
        <td>Devel</td>
        <td>2011-03-20</td>
        <td><a href="https://www.cpan.org/src/perl-5.13.11.tar.gz">perl-5.13.11.tar.gz</a></td>
    </tr>


    <tr class="latest">
        <td>5.12</td>
        <td>5.12.3
        <td>Maint</td>
        <td>2011-01-22</td>
        <td><a href="http://www.cpan.org/src/perl-5.12.3.tar.gz">perl-5.12.3.tar.gz</a></td>
    </tr>


    <tr >
        <td>5.10</td>
        <td>5.10.1
        <td>Maint</td>
        <td>2009-08-23</td>
        <td><a href="http://www.cpan.org/src/perl-5.10.1.tar.gz">perl-5.10.1.tar.gz</a></td>
    </tr>


    <tr >
        <td>5.8</td>
        <td>5.8.9
        <td>Maint</td>
        <td>2008-12-14</td>
        <td><a href="http://www.cpan.org/src/perl-5.8.9.tar.gz">perl-5.8.9.tar.gz</a></td>
    </tr>


    <tr >
        <td>5.6</td>
        <td>5.6.2
        <td>Maint</td>
        <td>2003-11-15</td>
        <td><a href="http://www.cpan.org/src/perl-5.6.2.tar.gz">perl-5.6.2.tar.gz</a></td>
    </tr>


    <tr >
        <td>5.5</td>
        <td>5.5.4
        <td>Maint</td>
        <td>2004-02-23</td>
        <td><a href="http://www.cpan.org/src/perl5.005_04.tar.gz">perl5.005_04.tar.gz</a></td>
    </tr>


    <tr >
        <td>5.4</td>
        <td>5.4.5
        <td>Maint</td>
        <td>1999-04-29</td>
        <td><a href="http://www.cpan.org/src/perl5.004_05.tar.gz">perl5.004_05.tar.gz</a></td>
    </tr>


    <tr >
        <td>5.3</td>
        <td>5.3.7
        <td>Maint</td>
        <td>1996-10-10</td>
        <td><a href="http://www.cpan.org/src/perl5.003_07.tar.gz">perl5.003_07.tar.gz</a></td>
    </tr>

</table>




<p>
    <a href="http://perldoc.perl.org/perlhist.html">Perl History</a>
</p>
<p>
    If you want to help out developing new releases of Perl visit the <a href=
    "http://dev.perl.org/perl5/">development site</a> and join the
    <a href="http://lists.perl.org/list/perl5-porters.html">perl5-porters</a> mailing list.
</p>

<h2>
    Version scheme
</h2>
<p>
    Perl has used the following <a href=
    "http://perldoc.perl.org/perlpolicy.html">policy</a> since the 5.6 release
    of Perl:
</p>
<ul>
    <li>Maintenance branches (ready for production use) are even numbers (5.8,
    5.10, 5.12 etc)
    </li>
    <li>Sub-branches of maintenance releases (5.12.1, 5.12.2 etc) are mostly
    just for bug fixes
    </li>
    <li>Development branches are odd numbers (5.9, 5.11, 5.13 etc)
    </li>
    <li>RC (release candidates) leading up to a maintenance branch are called
    testing releases
    </li>
</ul>
<p>
    Please note that branches earlier than 5.8 are no longer supported, though
    fixes for urgent issues, for example severe security problems, may
    still be issued.
</p>
<p>
    Note: please avoid referring to the "symbolic" source releases like
    "stable" and "latest", or "maint" and "devel". They are still used here but
    only for backward compatibility. The symbolic names were found to cause
    more confusion than they are worth because they don't really work with
    multiple branches, especially not with multiple maintenance branches, and
    especially the "latest" makes absolutely no sense. The "latest" and
    "stable" are now just aliases for "maint", and "maint" in turn is the
    maintenance branch with the largest release number.
</p>


<h2>First release in each branch of Perl</h2>


<table class="os_version">
    <tr class="table_header">
        <th>Major</th>
        <th>Version</th>
        <th>Released</th>
    </tr>


    <tr>
        <td>5.12</td>
        <td>5.12.0
        <td>2010-04-12</td>
    </tr>


    <tr>
        <td>5.10</td>
        <td>5.10.0
        <td>2007-12-18</td>
    </tr>


    <tr>
        <td>5.8</td>
        <td>5.8.0
        <td>2002-07-18</td>
    </tr>


    <tr>
        <td>5.6</td>
        <td>5.6.0
        <td>2000-03-22</td>
    </tr>


    <tr>
        <td>5.5</td>
        <td>5.5.0
        <td>1998-07-22</td>
    </tr>


    <tr>
        <td>5.4</td>
        <td>5.4.0
        <td>1997-05-15</td>
    </tr>


    <tr>
        <td>5.3</td>
        <td>5.3.7
        <td>1996-10-10</td>
    </tr>

</table>


<p></p>

<h2>
    Other files and directories (mostly for posterity)
</h2>
<ul>
    <li>
        <a href="5.0/">5.0/</a>
        <p>
            Source archives for all releases of perl5. You should only need to
            look here if you have an application which, for some reason or
            another, does not run with the current release of perl5. Be aware
            that only 5.004 and later versions of perl are maintained. If you
            report a genuine bug in such a version, you will probably be
            informed either that it is fixed in the current maintenance
            release, or will be fixed in a subsequent one. If you report a bug
            in an unmaintained version, you are likely to be advised to upgrade
            to a maintained version which fixes the bug, or to await a fix in a
            maintained version. No fix will be provided for the unmaintained
            version.
        </p>
    </li>
    <li>
        <p>
            Perl 6 or Parrot are not yet in CPAN. In the meanwhile, try
            <a href="http://dev.perl.org/perl6/">here</a> or <a href=
            "http://www.parrotcode.org/">here</a>.
        </p>
    </li>
    <li>
        <a href="5.0/jperl">5.0/jperl</a>
        <p>
            Path to patch files needed to adapt particular perl releases for
            use with Japanese character sets.
        </p>
    </li>
    <li>
        <a href="ENDINGS">ENDINGS</a>
        <p>
            Discussion of the meanings of the endings of filenames (.gz, .ZIP
            and so on). Read this file if you want to know how to handle a
            source code archive after you've downloaded it.
        </p>
    </li>
    <li>
        <a href="README">README</a>
        <p>
            This file.
        </p>
    </li>
    <li>
        <a href="misc/">misc/</a>
        <p>
            Third-party and other add-on source packages needed in order to
            build certain perl configurations. You do not need any of this
            stuff to build a default configuration.
        </p>
    </li>
    <li>perl-5.*.tar.gz, perl-5.*.tar.bz2, perl5_*.tar.gz
        <p>
            Source code archives for several recent production releases of
            perl.
        </p>
    </li>
    <li>
        <a href="unsupported/">unsupported/</a>
        <p>
            This is where we hid the source for perl4, which was superseded by
            perl5 years ago. We would really much rather that you didn't use
            it. It is definitely obsolete and has security and other bugs. And,
            since it's unsupported, it will continue to have them.
        </p>
    </li>
    <li>
        <a href="5.0/sperl-2000-08-05/">5.0/sperl-2000-08-05</a>
        <p>
            Files relevant to the security problem found in 'suidperl' in
            August 2000, reported in the bugtraq mailing list. The problem was
            found in all Perl release branches: 5.6, 5.005, and 5.004. The
            5.6.1 release has a fix for this, as have the 5.8 releases. The
            (now obsolete) development branch 5.7 was unaffected, except for
            very early (pre-5.7.0) developer-only snapshots. The bug affects
            you only if you use an executable called 'suidperl', not if you use
            'perl', and it is very likely only to affect UNIX platforms, and
            even more precisely, as of March 2001, the only platforms known to
            be affected are Linux platforms (all of them, <a href=
            "5.0/sperl-2000-08-05/sperl-2000-08-05.txt">as far as we know</a>).
            The 'suidperl' is an optional component which is not installed, or
            even built, by default. These files will help you in the case you
            compile Perl yourself from the source and you want to close the
            security hole.
        </p>
    </li>
    <li>
        <a href="5.0/CA-97.17.sperl">5.0/CA-97.17.sperl</a>
    </li>
    <li>
        <a href="5.0/fixsperl-0">5.0/fixsperl-0</a>
    </li>
    <li>
        <a href="5.0/fixsuid5-0.pat">5.0/fixsuid5-0.pat</a>
        <p>
            Files relevant to the CERT Advisory CA-97.17.sperl, a security
            problem found in 'suidperl' back in 1997. The problem was found
            both in Perl 4.036 (the final) (and last) release of Perl 4 and in
            early versions of Perl 5 (pre-5.003). The bug affects you only if
            you use an executable called 'suidperl', not if you use 'perl', and
            it is very likely only to affect UNIX platform. The 'suidperl' is
            an optional component which is not installed, or even built, by
            default. These files will help you in the (very unlikely) case you
            need to use (the obsolete and unsupported) Perl 4 or the early Perl
            5s, <b>Perl releases newer than Perl 5.003 do not have this
            security problem.</b>
        </p>
    </li>
</ul>



















            </div>
        </td>
    </tr>
    <tr>
        <td id="footer">
            <div id="footer_copyright">
                <p>Yours Eclectically, The Self-Appointed Master Librarians (<i>OOK!</i>) of the CPAN.<br/>
                   &copy; 1995-2010 Jarkko Hietaniemi.
                   &copy; 2011 <a href="http://www.perl.org">Perl.org</a>.
                   All rights reserved.
                   <a href="../disclaimer.html">Disclaimer</a>.
                </p>
            </div>


            <div id="footer_mirror">
			<p>Master mirror hosted by <a href="http://www.yellowbot.com/"><img alt="YellowBot" src="../misc/images/yellowbot.png" /></a></p>
            </div>



        </td>
    </tr>
</table>


</body>
</html>
EOF
}

sub read_metacpan_html {
    return <<'EOF';
{
   "hits" : {
      "total" : 41,
      "max_score" : 3.36797,
      "hits" : [
         {
            "_score" : 3.36797,
            "_type" : "release",
            "_index" : "cpan_v1_01",
            "_id" : "cwysy_LCh_cU4sYkQq_XhqwRzVM",
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/R/RG/RGARCIA/perl-5.9.5.tar.gz"
            }
         },
         {
            "_id" : "6bF8joctVyZMfTxAK6oBCKXxrN0",
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/R/RG/RGARCIA/perl-5.9.3.tar.gz"
            },
            "_score" : 3.36797,
            "_index" : "cpan_v1_01",
            "_type" : "release"
         },
         {
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/S/SR/SREZIC/perl-5.005-Tk-800.023-bin-0-arm-linux.tar.gz"
            },
            "_id" : "j6U8yM_m0OKRWGLvUfc_9nGKjoQ",
            "_type" : "release",
            "_index" : "cpan_v1_01",
            "_score" : 3.36797
         },
         {
            "_id" : "g1FYWtQPcw6yrR5dXP2fYH6I1zo",
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/G/GS/GSAR/perl-5.6.1.tar.gz"
            },
            "_score" : 3.36797,
            "_index" : "cpan_v1_01",
            "_type" : "release"
         },
         {
            "_index" : "cpan_v1_01",
            "_type" : "release",
            "_score" : 3.36797,
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/G/GS/GSAR/perl-5.6.1-TRIAL3.tar.gz"
            },
            "_id" : "SIqDQs0lJGmbEPj_05cIPlPfR_A"
         },
         {
            "_id" : "JuBrDjYXwrh_k_5_FMkZjseSuOw",
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/G/GS/GSAR/perl-5.6.1-TRIAL2.tar.gz"
            },
            "_score" : 3.36797,
            "_index" : "cpan_v1_01",
            "_type" : "release"
         },
         {
            "_id" : "ElW8WK1SAx3LISaIm_GZ6WWly1M",
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/A/AB/ABIGAIL/perl-5.27.8.tar.gz"
            },
            "_score" : 3.36797,
            "_type" : "release",
            "_index" : "cpan_v1_01"
         },
         {
            "_id" : "bDbuaoHU6C4UjauBqFqovDALEJY",
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.22.4-RC1.tar.gz"
            },
            "_score" : 3.36797,
            "_index" : "cpan_v1_01",
            "_type" : "release"
         },
         {
            "_index" : "cpan_v1_01",
            "_type" : "release",
            "_score" : 3.36797,
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.24.3.tar.gz"
            },
            "_id" : "MLhHV7zvJ2zZ5e_I3MKfsk_iM6A"
         },
         {
            "_id" : "fag73WWtL5Q1HZlFk_yryqfqnrE",
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.27.5.tar.gz"
            },
            "_score" : 3.36797,
            "_index" : "cpan_v1_01",
            "_type" : "release"
         },
         {
            "_index" : "cpan_v1_01",
            "_type" : "release",
            "_score" : 3.36797,
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.22.1.tar.gz"
            },
            "_id" : "36dFZmJHuKH4pMdUH0khXuWS2LE"
         },
         {
            "_index" : "cpan_v1_01",
            "_type" : "release",
            "_score" : 3.36797,
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.24.2.tar.gz"
            },
            "_id" : "1rwJbxpit3uIv6lk5WcUe4zxxSA"
         },
         {
            "_type" : "release",
            "_index" : "cpan_v1_01",
            "_score" : 3.36797,
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/X/XS/XSAWYERX/perl-5.27.11.tar.gz"
            },
            "_id" : "riJj4D3ZWS49kglzdtz8h19xp7Y"
         },
         {
            "_type" : "release",
            "_index" : "cpan_v1_01",
            "_score" : 3.36797,
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/J/JH/JHI/perl-5.7.3.tar.gz"
            },
            "_id" : "Qb4oEns73TILHWaO9S3kY86yb4A"
         },
         {
            "_score" : 3.36797,
            "_type" : "release",
            "_index" : "cpan_v1_01",
            "_id" : "IxX27a_qsQxaRHI883PqEOMNs9A",
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.26.2-RC1.tar.gz"
            }
         },
         {
            "_id" : "MpJJPG9eHPVjo5LHWPyl7uIn2sU",
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/X/XS/XSAWYERX/perl-5.28.0-RC1.tar.gz"
            },
            "_score" : 3.36797,
            "_type" : "release",
            "_index" : "cpan_v1_01"
         },
         {
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/X/XS/XSAWYERX/perl-5.28.0-RC2.tar.gz"
            },
            "_id" : "ykCB3f8FK_sNN4FuXiMsixTc4r0",
            "_index" : "cpan_v1_01",
            "_type" : "release",
            "_score" : 3.36797
         },
         {
            "_score" : 3.36797,
            "_type" : "release",
            "_index" : "cpan_v1_01",
            "_id" : "SPMWYdPjP_a76kz9tjMfhGNBgaA",
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.26.2.tar.gz"
            }
         },
         {
            "_type" : "release",
            "_index" : "cpan_v1_01",
            "_score" : 3.36797,
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/X/XS/XSAWYERX/perl-5.28.0.tar.gz"
            },
            "_id" : "6YbmfIXsv0IghoL8RsswA6Bcl8M"
         },
         {
            "_id" : "H6QF57CTY4HWj4rx_Urxy2Kk5pA",
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/G/GS/GSAR/perl-5.6.1-TRIAL1.tar.gz"
            },
            "_score" : 3.2532742,
            "_index" : "cpan_v1_01",
            "_type" : "release"
         },
         {
            "_type" : "release",
            "_index" : "cpan_v1_01",
            "_score" : 3.2532742,
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/G/GS/GSAR/perl-5.6.0.tar.gz"
            },
            "_id" : "7MIXoXAMLZWlXfwWTs7L3w26rqk"
         },
         {
            "_id" : "wXO4aI747e_DU6R7DNe3J8s7wsw",
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/J/JH/JHI/perl-5.7.0.tar.gz"
            },
            "_score" : 3.2532742,
            "_type" : "release",
            "_index" : "cpan_v1_01"
         },
         {
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/J/JH/JHI/perl-5.8.0.tar.gz"
            },
            "_id" : "nNi1Knyqy7wSnH_mKvSfhl_deGo",
            "_index" : "cpan_v1_01",
            "_type" : "release",
            "_score" : 3.2532742
         },
         {
            "_index" : "cpan_v1_01",
            "_type" : "release",
            "_score" : 3.2532742,
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/R/RG/RGARCIA/perl-5.10.0.tar.gz"
            },
            "_id" : "wfc7JJwuCTJvmW9C4J4tZIActHM"
         },
         {
            "_id" : "GhF4X5JX3OhldWnA_I1t_r4NipE",
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/R/RG/RGARCIA/perl-5.9.1.tar.gz"
            },
            "_score" : 3.2532742,
            "_index" : "cpan_v1_01",
            "_type" : "release"
         },
         {
            "_score" : 3.2532742,
            "_index" : "cpan_v1_01",
            "_type" : "release",
            "_id" : "9X4t_9wlwZJMS5d5jIUEdnL1SCA",
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/R/RG/RGARCIA/perl-5.6.2.tar.gz"
            }
         },
         {
            "_index" : "cpan_v1_01",
            "_type" : "release",
            "_score" : 3.2532742,
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/E/ET/ETHER/perl-5.27.6.tar.gz"
            },
            "_id" : "TwgEl_BI7dKp3BQvZkKqQia5qcU"
         },
         {
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/A/AB/ABIGAIL/perl-5.25.9.tar.gz"
            },
            "_id" : "VQfl2bwzqY1bl4tfZmxFaFRY5y8",
            "_index" : "cpan_v1_01",
            "_type" : "release",
            "_score" : 3.2532742
         },
         {
            "_index" : "cpan_v1_01",
            "_type" : "release",
            "_score" : 3.2532742,
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.24.4-RC1.tar.gz"
            },
            "_id" : "ElYIbWVnjcBLopeXvYgo7HSk5Ic"
         },
         {
            "_id" : "DitFBkE2r0aGkPcjH36PbRagPcs",
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/X/XS/XSAWYERX/perl-5.28.0-RC3.tar.gz"
            },
            "_score" : 3.2532742,
            "_index" : "cpan_v1_01",
            "_type" : "release"
         },
         {
            "_index" : "cpan_v1_01",
            "_type" : "release",
            "_score" : 3.2532742,
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/X/XS/XSAWYERX/perl-5.28.0-RC4.tar.gz"
            },
            "_id" : "zn33iw3HnI2_5phH9rAhFNmoUps"
         },
         {
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/R/RE/RENEEB/perl-5.27.9.tar.gz"
            },
            "_id" : "AuenBK2ImZIVxVzxN0zgVjsunSs",
            "_index" : "cpan_v1_01",
            "_type" : "release",
            "_score" : 3.1751823
         },
         {
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/T/TO/TODDR/perl-5.27.10.tar.gz"
            },
            "_id" : "_SySZ7HuT9fCjnvKlyUlAAyA7WY",
            "_type" : "release",
            "_index" : "cpan_v1_01",
            "_score" : 3.1751823
         },
         {
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.24.4.tar.gz"
            },
            "_id" : "k4tD0K2qrojzSwtfXA5A_oxu074",
            "_index" : "cpan_v1_01",
            "_type" : "release",
            "_score" : 3.1751823
         },
         {
            "_id" : "QfS1_HGycjW44MsCl73JLC8Is_s",
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/J/JH/JHI/perl-5.8.1.tar.gz"
            },
            "_score" : 3.1751823,
            "_type" : "release",
            "_index" : "cpan_v1_01"
         },
         {
            "_score" : 3.1751823,
            "_index" : "cpan_v1_01",
            "_type" : "release",
            "_id" : "CGvg1FBsux5HoXiu7leipfdMTEc",
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/J/JH/JHI/perl-5.7.2.tar.gz"
            }
         },
         {
            "_type" : "release",
            "_index" : "cpan_v1_01",
            "_score" : 3.1751823,
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/R/RG/RGARCIA/perl-5.9.2.tar.gz"
            },
            "_id" : "yvVmPixkFaUceARSy1aKqRPPDBs"
         },
         {
            "_score" : 3.1751823,
            "_index" : "cpan_v1_01",
            "_type" : "release",
            "_id" : "47VQmSAIhurcr84X44RXyKqUMdw",
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/R/RG/RGARCIA/perl-5.9.4.tar.gz"
            }
         },
         {
            "_score" : 3.1751823,
            "_type" : "release",
            "_index" : "cpan_v1_01",
            "_id" : "hTJckZ5tEZko8OdmnS8QbWKs10w",
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/B/BI/BINGOS/perl-5.27.7.tar.gz"
            }
         },
         {
            "_type" : "release",
            "_index" : "cpan_v1_01",
            "_score" : 3.1751823,
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/R/RE/RENEEB/perl-5.25.10.tar.gz"
            },
            "_id" : "WAMqkmWfSSlBLcSwGZb5DlDD25U"
         },
         {
            "_id" : "bMUgwm4eIPz1ljDFi6aBBFMf6dA",
            "fields" : {
               "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.22.3.tar.gz"
            },
            "_score" : 3.1751823,
            "_type" : "release",
            "_index" : "cpan_v1_01"
         }
      ]
   },
   "_shards" : {
      "failed" : 0,
      "total" : 3,
      "successful" : 3
   },
   "took" : 9,
   "timed_out" : false
}
EOF
}
