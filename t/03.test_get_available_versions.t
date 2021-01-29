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

plan tests => 17;

my $app = App::perlbrew->new();
my $dists = $app->available_perl_distributions();
my @vers = $app->sort_perl_versions(keys %$dists);
is scalar( @vers ), 16, "Correct number of releases found";

my @known_perl_versions = (
    'perl-5.28.0',  'perl-5.26.2',  'perl-5.24.4',  'perl-5.22.4',
    'perl-5.20.3',  'perl-5.18.4',  'perl-5.16.3',  'perl-5.14.4',
    'perl-5.13.11', 'perl-5.12.5',  'perl-5.10.1',  'perl-5.8.9',
    'perl-5.6.2',   'perl5.005_04', 'perl5.004_05', 'perl5.003_07'
);

for my $perl_version ( @vers ) {
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
        <td><a href="https://www.cpan.org/src/perl-5.13.11.tar.bz2">perl-5.13.11.tar.bz2</a></td>
    </tr>


    <tr class="latest">
        <td>5.12</td>
        <td>5.12.5
        <td>Maint</td>
        <td>2011-01-22</td>
        <td><a href="http://www.cpan.org/src/perl-5.12.5.tar.gz">perl-5.12.5.tar.gz</a></td>
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
   "releases" : [
      {
         "authorized" : true,
         "version" : "5.028000",
         "maturity" : "released",
         "status" : "latest",
         "name" : "perl-5.28.0",
         "date" : "2018-06-23T02:05:28",
         "download_url" : "https://cpan.metacpan.org/authors/id/X/XS/XSAWYERX/perl-5.28.0.tar.gz",
         "author" : "XSAWYERX"
      },
      {
         "name" : "perl-5.28.0-RC4",
         "maturity" : "developer",
         "status" : "cpan",
         "authorized" : true,
         "version" : "5.028000",
         "author" : "XSAWYERX",
         "download_url" : "https://cpan.metacpan.org/authors/id/X/XS/XSAWYERX/perl-5.28.0-RC4.tar.gz",
         "date" : "2018-06-19T20:45:05"
      },
      {
         "date" : "2018-06-18T22:47:34",
         "download_url" : "https://cpan.metacpan.org/authors/id/X/XS/XSAWYERX/perl-5.28.0-RC3.tar.gz",
         "author" : "XSAWYERX",
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.28.0-RC3",
         "version" : "5.028000",
         "authorized" : true
      },
      {
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.28.0-RC2",
         "version" : "5.028000",
         "authorized" : true,
         "author" : "XSAWYERX",
         "download_url" : "https://cpan.metacpan.org/authors/id/X/XS/XSAWYERX/perl-5.28.0-RC2.tar.gz",
         "date" : "2018-06-06T12:34:00"
      },
      {
         "version" : "5.028000",
         "authorized" : true,
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.28.0-RC1",
         "date" : "2018-05-21T13:12:00",
         "author" : "XSAWYERX",
         "download_url" : "https://cpan.metacpan.org/authors/id/X/XS/XSAWYERX/perl-5.28.0-RC1.tar.gz"
      },
      {
         "version" : "5.027011",
         "authorized" : true,
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.27.11",
         "author" : "XSAWYERX",
         "download_url" : "https://cpan.metacpan.org/authors/id/X/XS/XSAWYERX/perl-5.27.11.tar.gz",
         "date" : "2018-04-20T15:10:52"
      },
      {
         "date" : "2018-04-14T11:27:18",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.26.2.tar.gz",
         "author" : "SHAY",
         "name" : "perl-5.26.2",
         "maturity" : "released",
         "status" : "cpan",
         "authorized" : true,
         "version" : "5.026002"
      },
      {
         "date" : "2018-04-14T11:25:22",
         "author" : "SHAY",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.24.4.tar.gz",
         "version" : "5.024004",
         "authorized" : true,
         "name" : "perl-5.24.4",
         "status" : "cpan",
         "maturity" : "released"
      },
      {
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.26.2-RC1",
         "version" : "5.026002",
         "authorized" : true,
         "author" : "SHAY",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.26.2-RC1.tar.gz",
         "date" : "2018-03-24T19:37:40"
      },
      {
         "version" : "5.024004",
         "authorized" : true,
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.24.4-RC1",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.24.4-RC1.tar.gz",
         "author" : "SHAY",
         "date" : "2018-03-24T19:33:50"
      },
      {
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.27.10",
         "version" : "5.027010",
         "authorized" : true,
         "date" : "2018-03-20T21:08:53",
         "download_url" : "https://cpan.metacpan.org/authors/id/T/TO/TODDR/perl-5.27.10.tar.gz",
         "author" : "TODDR"
      },
      {
         "date" : "2018-02-20T20:46:45",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RE/RENEEB/perl-5.27.9.tar.gz",
         "author" : "RENEEB",
         "name" : "perl-5.27.9",
         "maturity" : "developer",
         "status" : "cpan",
         "authorized" : true,
         "version" : "5.027009"
      },
      {
         "authorized" : true,
         "version" : "5.027008",
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.27.8",
         "download_url" : "https://cpan.metacpan.org/authors/id/A/AB/ABIGAIL/perl-5.27.8.tar.gz",
         "author" : "ABIGAIL",
         "date" : "2018-01-20T03:17:50"
      },
      {
         "date" : "2017-12-20T22:58:25",
         "download_url" : "https://cpan.metacpan.org/authors/id/B/BI/BINGOS/perl-5.27.7.tar.gz",
         "author" : "BINGOS",
         "version" : "5.027007",
         "authorized" : true,
         "name" : "perl-5.27.7",
         "status" : "cpan",
         "maturity" : "developer"
      },
      {
         "download_url" : "https://cpan.metacpan.org/authors/id/E/ET/ETHER/perl-5.27.6.tar.gz",
         "author" : "ETHER",
         "date" : "2017-11-20T22:39:31",
         "name" : "perl-5.27.6",
         "status" : "cpan",
         "maturity" : "developer",
         "authorized" : true,
         "version" : "5.027006"
      },
      {
         "name" : "perl-5.27.5",
         "maturity" : "developer",
         "status" : "cpan",
         "authorized" : true,
         "version" : "5.027005",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.27.5.tar.gz",
         "author" : "SHAY",
         "date" : "2017-10-20T22:08:15"
      },
      {
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.26.1.tar.bz2",
         "author" : "SHAY",
         "date" : "2017-09-22T21:30:18",
         "authorized" : true,
         "version" : "5.026001",
         "status" : "latest",
         "maturity" : "released",
         "name" : "perl-5.26.1"
      },
      {
         "date" : "2017-09-22T21:29:50",
         "author" : "SHAY",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.24.3.tar.gz",
         "authorized" : true,
         "version" : "5.024003",
         "status" : "cpan",
         "maturity" : "released",
         "name" : "perl-5.24.3"
      },
      {
         "author" : "GENEHACK",
         "download_url" : "https://cpan.metacpan.org/authors/id/G/GE/GENEHACK/perl-5.27.4.tar.bz2",
         "date" : "2017-09-20T21:44:22",
         "version" : "5.027004",
         "authorized" : true,
         "name" : "perl-5.27.4",
         "status" : "cpan",
         "maturity" : "developer"
      },
      {
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.26.1-RC1",
         "version" : "5.026001",
         "authorized" : true,
         "author" : "SHAY",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.26.1-RC1.tar.bz2",
         "date" : "2017-09-10T15:38:22"
      },
      {
         "authorized" : true,
         "version" : "5.024003",
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.24.3-RC1",
         "author" : "SHAY",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.24.3-RC1.tar.bz2",
         "date" : "2017-09-10T15:37:08"
      },
      {
         "author" : "WOLFSAGE",
         "download_url" : "https://cpan.metacpan.org/authors/id/W/WO/WOLFSAGE/perl-5.27.3.tar.bz2",
         "date" : "2017-08-21T20:43:51",
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.27.3",
         "authorized" : true,
         "version" : "5.027003"
      },
      {
         "name" : "perl-5.27.2",
         "status" : "cpan",
         "maturity" : "developer",
         "authorized" : true,
         "version" : "5.027002",
         "date" : "2017-07-20T19:28:36",
         "author" : "ARC",
         "download_url" : "https://cpan.metacpan.org/authors/id/A/AR/ARC/perl-5.27.2.tar.bz2"
      },
      {
         "version" : "5.024002",
         "authorized" : true,
         "name" : "perl-5.24.2",
         "maturity" : "released",
         "status" : "cpan",
         "author" : "SHAY",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.24.2.tar.gz",
         "date" : "2017-07-15T17:29:00"
      },
      {
         "date" : "2017-07-15T17:26:52",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.22.4.tar.bz2",
         "author" : "SHAY",
         "authorized" : true,
         "version" : "5.022004",
         "maturity" : "released",
         "status" : "cpan",
         "name" : "perl-5.22.4"
      },
      {
         "version" : "5.024002",
         "authorized" : true,
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.24.2-RC1",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.24.2-RC1.tar.bz2",
         "author" : "SHAY",
         "date" : "2017-07-01T21:50:55"
      },
      {
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.22.4-RC1",
         "authorized" : true,
         "version" : "5.022004",
         "date" : "2017-07-01T21:50:24",
         "author" : "SHAY",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.22.4-RC1.tar.gz"
      },
      {
         "name" : "perl-5.27.1",
         "status" : "cpan",
         "maturity" : "developer",
         "authorized" : true,
         "version" : "5.027001",
         "download_url" : "https://cpan.metacpan.org/authors/id/E/EH/EHERMAN/perl-5.27.1.tar.bz2",
         "author" : "EHERMAN",
         "date" : "2017-06-20T06:39:54"
      },
      {
         "maturity" : "developer",
         "status" : "backpan",
         "name" : "perl-5.27.0",
         "version" : "5.027000",
         "authorized" : true,
         "author" : "XSAWYERX",
         "download_url" : "https://cpan.metacpan.org/authors/id/X/XS/XSAWYERX/perl-5.27.0.tar.gz",
         "date" : "2017-05-31T21:11:57"
      },
      {
         "download_url" : "https://cpan.metacpan.org/authors/id/X/XS/XSAWYERX/perl-5.26.0.tar.bz2",
         "author" : "XSAWYERX",
         "date" : "2017-05-30T19:42:51",
         "authorized" : true,
         "version" : "5.026000",
         "status" : "cpan",
         "maturity" : "released",
         "name" : "perl-5.26.0"
      },
      {
         "name" : "perl-5.26.0-RC2",
         "maturity" : "developer",
         "status" : "backpan",
         "authorized" : true,
         "version" : "5.026000",
         "download_url" : "https://cpan.metacpan.org/authors/id/X/XS/XSAWYERX/perl-5.26.0-RC2.tar.gz",
         "author" : "XSAWYERX",
         "date" : "2017-05-23T23:19:34"
      },
      {
         "name" : "perl-5.26.0-RC1",
         "status" : "backpan",
         "maturity" : "developer",
         "authorized" : true,
         "version" : "5.026000",
         "author" : "XSAWYERX",
         "download_url" : "https://cpan.metacpan.org/authors/id/X/XS/XSAWYERX/perl-5.26.0-RC1.tar.bz2",
         "date" : "2017-05-11T17:07:17"
      },
      {
         "author" : "XSAWYERX",
         "download_url" : "https://cpan.metacpan.org/authors/id/X/XS/XSAWYERX/perl-5.25.12.tar.gz",
         "date" : "2017-04-20T19:32:05",
         "maturity" : "developer",
         "status" : "backpan",
         "name" : "perl-5.25.12",
         "version" : "5.025012",
         "authorized" : true
      },
      {
         "author" : "XSAWYERX",
         "download_url" : "https://cpan.metacpan.org/authors/id/X/XS/XSAWYERX/perl-5.25.11.tar.gz",
         "date" : "2017-03-20T20:56:49",
         "version" : "5.025011",
         "authorized" : true,
         "maturity" : "developer",
         "status" : "backpan",
         "name" : "perl-5.25.11"
      },
      {
         "date" : "2017-02-20T21:21:01",
         "author" : "RENEEB",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RE/RENEEB/perl-5.25.10.tar.gz",
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.25.10",
         "version" : "5.025010",
         "authorized" : true
      },
      {
         "name" : "perl-5.25.9",
         "maturity" : "developer",
         "status" : "cpan",
         "version" : "5.025009",
         "authorized" : true,
         "date" : "2017-01-20T15:25:43",
         "download_url" : "https://cpan.metacpan.org/authors/id/A/AB/ABIGAIL/perl-5.25.9.tar.gz",
         "author" : "ABIGAIL"
      },
      {
         "authorized" : true,
         "version" : "5.024001",
         "name" : "perl-5.24.1",
         "status" : "cpan",
         "maturity" : "released",
         "author" : "SHAY",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.24.1.tar.bz2",
         "date" : "2017-01-14T20:04:30"
      },
      {
         "date" : "2017-01-14T20:04:05",
         "author" : "SHAY",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.22.3.tar.gz",
         "maturity" : "released",
         "status" : "cpan",
         "name" : "perl-5.22.3",
         "version" : "5.022003",
         "authorized" : true
      },
      {
         "date" : "2017-01-02T18:57:38",
         "author" : "SHAY",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.24.1-RC5.tar.bz2",
         "authorized" : true,
         "version" : "5.024001",
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.24.1-RC5"
      },
      {
         "authorized" : true,
         "version" : "5.022003",
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.22.3-RC5",
         "date" : "2017-01-02T18:54:51",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.22.3-RC5.tar.bz2",
         "author" : "SHAY"
      },
      {
         "authorized" : true,
         "version" : "5.025008",
         "name" : "perl-5.25.8",
         "status" : "backpan",
         "maturity" : "developer",
         "date" : "2016-12-20T19:14:33",
         "author" : "XSAWYERX",
         "download_url" : "https://cpan.metacpan.org/authors/id/X/XS/XSAWYERX/perl-5.25.8.tar.gz"
      },
      {
         "name" : "perl-5.25.7",
         "status" : "cpan",
         "maturity" : "developer",
         "authorized" : true,
         "version" : "5.025007",
         "date" : "2016-11-20T21:20:07",
         "author" : "EXODIST",
         "download_url" : "https://cpan.metacpan.org/authors/id/E/EX/EXODIST/perl-5.25.7.tar.bz2"
      },
      {
         "date" : "2016-10-20T15:44:55",
         "author" : "ARC",
         "download_url" : "https://cpan.metacpan.org/authors/id/A/AR/ARC/perl-5.25.6.tar.bz2",
         "version" : "5.025006",
         "authorized" : true,
         "name" : "perl-5.25.6",
         "status" : "cpan",
         "maturity" : "developer"
      },
      {
         "authorized" : true,
         "version" : "5.024001",
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.24.1-RC4",
         "author" : "SHAY",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.24.1-RC4.tar.bz2",
         "date" : "2016-10-12T21:40:57"
      },
      {
         "authorized" : true,
         "version" : "5.022003",
         "name" : "perl-5.22.3-RC4",
         "status" : "cpan",
         "maturity" : "developer",
         "date" : "2016-10-12T21:39:57",
         "author" : "SHAY",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.22.3-RC4.tar.bz2"
      },
      {
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.25.5",
         "authorized" : true,
         "version" : "5.025005",
         "date" : "2016-09-20T17:45:06",
         "author" : "STEVAN",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/ST/STEVAN/perl-5.25.5.tar.bz2"
      },
      {
         "date" : "2016-08-20T20:25:19",
         "author" : "BINGOS",
         "download_url" : "https://cpan.metacpan.org/authors/id/B/BI/BINGOS/perl-5.25.4.tar.bz2",
         "version" : "5.025004",
         "authorized" : true,
         "name" : "perl-5.25.4",
         "maturity" : "developer",
         "status" : "cpan"
      },
      {
         "date" : "2016-08-11T23:50:29",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.24.1-RC3.tar.bz2",
         "author" : "SHAY",
         "version" : "5.024001",
         "authorized" : true,
         "name" : "perl-5.24.1-RC3",
         "status" : "cpan",
         "maturity" : "developer"
      },
      {
         "authorized" : true,
         "version" : "5.022003",
         "name" : "perl-5.22.3-RC3",
         "status" : "cpan",
         "maturity" : "developer",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.22.3-RC3.tar.bz2",
         "author" : "SHAY",
         "date" : "2016-08-11T23:47:40"
      },
      {
         "authorized" : true,
         "version" : "5.024001",
         "name" : "perl-5.24.1-RC2",
         "maturity" : "developer",
         "status" : "cpan",
         "author" : "SHAY",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.24.1-RC2.tar.bz2",
         "date" : "2016-07-25T13:01:21"
      },
      {
         "version" : "5.022003",
         "authorized" : true,
         "name" : "perl-5.22.3-RC2",
         "status" : "cpan",
         "maturity" : "developer",
         "author" : "SHAY",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.22.3-RC2.tar.bz2",
         "date" : "2016-07-25T12:58:33"
      },
      {
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.25.3",
         "version" : "5.025003",
         "authorized" : true,
         "date" : "2016-07-20T16:22:41",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.25.3.tar.bz2",
         "author" : "SHAY"
      },
      {
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.24.1-RC1",
         "version" : "5.024001",
         "authorized" : true,
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.24.1-RC1.tar.bz2",
         "author" : "SHAY",
         "date" : "2016-07-17T22:29:08"
      },
      {
         "version" : "5.022003",
         "authorized" : true,
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.22.3-RC1",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.22.3-RC1.tar.bz2",
         "author" : "SHAY",
         "date" : "2016-07-17T22:27:32"
      },
      {
         "author" : "WOLFSAGE",
         "download_url" : "https://cpan.metacpan.org/authors/id/W/WO/WOLFSAGE/perl-5.25.2.tar.bz2",
         "date" : "2016-06-20T21:02:44",
         "name" : "perl-5.25.2",
         "maturity" : "developer",
         "status" : "cpan",
         "version" : "5.025002",
         "authorized" : true
      },
      {
         "author" : "XSAWYERX",
         "download_url" : "https://cpan.metacpan.org/authors/id/X/XS/XSAWYERX/perl-5.25.1.tar.bz2",
         "date" : "2016-05-20T21:33:43",
         "name" : "perl-5.25.1",
         "status" : "backpan",
         "maturity" : "developer",
         "authorized" : true,
         "version" : "5.025001"
      },
      {
         "date" : "2016-05-09T12:02:53",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.25.0.tar.bz2",
         "author" : "RJBS",
         "version" : "5.025000",
         "authorized" : true,
         "name" : "perl-5.25.0",
         "maturity" : "developer",
         "status" : "cpan"
      },
      {
         "authorized" : true,
         "version" : "5.024000",
         "maturity" : "released",
         "status" : "cpan",
         "name" : "perl-5.24.0",
         "date" : "2016-05-09T11:35:29",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.24.0.tar.bz2",
         "author" : "RJBS"
      },
      {
         "name" : "perl-5.24.0-RC5",
         "status" : "cpan",
         "maturity" : "developer",
         "version" : "5.024000",
         "authorized" : true,
         "date" : "2016-05-04T22:27:57",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.24.0-RC5.tar.bz2",
         "author" : "RJBS"
      },
      {
         "version" : "5.024000",
         "authorized" : true,
         "name" : "perl-5.24.0-RC4",
         "maturity" : "developer",
         "status" : "cpan",
         "date" : "2016-05-02T14:41:03",
         "author" : "RJBS",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.24.0-RC4.tar.bz2"
      },
      {
         "date" : "2016-04-29T21:39:25",
         "author" : "SHAY",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.22.2.tar.bz2",
         "version" : "5.022002",
         "authorized" : true,
         "status" : "cpan",
         "maturity" : "released",
         "name" : "perl-5.22.2"
      },
      {
         "version" : "5.024000",
         "authorized" : true,
         "name" : "perl-5.24.0-RC3",
         "maturity" : "developer",
         "status" : "cpan",
         "date" : "2016-04-27T01:02:55",
         "author" : "RJBS",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.24.0-RC3.tar.bz2"
      },
      {
         "authorized" : true,
         "version" : "5.024000",
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.24.0-RC2",
         "author" : "RJBS",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.24.0-RC2.tar.bz2",
         "date" : "2016-04-23T20:56:14"
      },
      {
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.24.0-RC1",
         "version" : "5.024000",
         "authorized" : true,
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.24.0-RC1.tar.bz2",
         "author" : "RJBS",
         "date" : "2016-04-14T03:27:48"
      },
      {
         "authorized" : true,
         "version" : "5.022002",
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.22.2-RC1",
         "date" : "2016-04-10T17:29:04",
         "author" : "SHAY",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.22.2-RC1.tar.bz2"
      },
      {
         "date" : "2016-03-20T16:45:40",
         "download_url" : "https://cpan.metacpan.org/authors/id/A/AB/ABIGAIL/perl-5.23.9.tar.bz2",
         "author" : "ABIGAIL",
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.23.9",
         "authorized" : true,
         "version" : "5.023009"
      },
      {
         "authorized" : true,
         "version" : "5.023008",
         "status" : "backpan",
         "maturity" : "developer",
         "name" : "perl-5.23.8",
         "date" : "2016-02-20T21:56:31",
         "download_url" : "https://cpan.metacpan.org/authors/id/X/XS/XSAWYERX/perl-5.23.8.tar.bz2",
         "author" : "XSAWYERX"
      },
      {
         "name" : "perl-5.23.7",
         "maturity" : "developer",
         "status" : "cpan",
         "version" : "5.023007",
         "authorized" : true,
         "date" : "2016-01-20T21:52:22",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/ST/STEVAN/perl-5.23.7.tar.bz2",
         "author" : "STEVAN"
      },
      {
         "date" : "2015-12-21T22:40:27",
         "download_url" : "https://cpan.metacpan.org/authors/id/D/DA/DAGOLDEN/perl-5.23.6.tar.bz2",
         "author" : "DAGOLDEN",
         "name" : "perl-5.23.6",
         "status" : "cpan",
         "maturity" : "developer",
         "authorized" : true,
         "version" : "5.023006"
      },
      {
         "version" : "5.022001",
         "authorized" : true,
         "status" : "cpan",
         "maturity" : "released",
         "name" : "perl-5.22.1",
         "date" : "2015-12-13T19:48:31",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.22.1.tar.gz",
         "author" : "SHAY"
      },
      {
         "version" : "5.022001",
         "authorized" : true,
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.22.1-RC4",
         "date" : "2015-12-08T21:34:05",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.22.1-RC4.tar.bz2",
         "author" : "SHAY"
      },
      {
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.22.1-RC3.tar.bz2",
         "author" : "SHAY",
         "date" : "2015-12-02T22:07:35",
         "version" : "5.022001",
         "authorized" : true,
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.22.1-RC3"
      },
      {
         "authorized" : true,
         "version" : "5.023005",
         "name" : "perl-5.23.5",
         "maturity" : "developer",
         "status" : "cpan",
         "author" : "ABIGAIL",
         "download_url" : "https://cpan.metacpan.org/authors/id/A/AB/ABIGAIL/perl-5.23.5.tar.bz2",
         "date" : "2015-11-20T17:09:38"
      },
      {
         "date" : "2015-11-15T15:15:03",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.22.1-RC2.tar.bz2",
         "author" : "SHAY",
         "authorized" : true,
         "version" : "5.022001",
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.22.1-RC2"
      },
      {
         "date" : "2015-10-31T18:42:58",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.22.1-RC1.tar.bz2",
         "author" : "SHAY",
         "authorized" : true,
         "version" : "5.022001",
         "name" : "perl-5.22.1-RC1",
         "status" : "cpan",
         "maturity" : "developer"
      },
      {
         "date" : "2015-10-20T22:17:48",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.23.4.tar.bz2",
         "author" : "SHAY",
         "authorized" : true,
         "version" : "5.023004",
         "name" : "perl-5.23.4",
         "maturity" : "developer",
         "status" : "cpan"
      },
      {
         "version" : "5.023003",
         "authorized" : true,
         "name" : "perl-5.23.3",
         "maturity" : "developer",
         "status" : "cpan",
         "date" : "2015-09-21T02:47:16",
         "author" : "PCM",
         "download_url" : "https://cpan.metacpan.org/authors/id/P/PC/PCM/perl-5.23.3.tar.bz2"
      },
      {
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.20.3.tar.bz2",
         "author" : "SHAY",
         "date" : "2015-09-12T19:09:14",
         "version" : "5.020003",
         "authorized" : true,
         "status" : "cpan",
         "maturity" : "released",
         "name" : "perl-5.20.3"
      },
      {
         "date" : "2015-08-29T22:02:43",
         "author" : "SHAY",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.20.3-RC2.tar.bz2",
         "authorized" : true,
         "version" : "5.020003",
         "name" : "perl-5.20.3-RC2",
         "status" : "cpan",
         "maturity" : "developer"
      },
      {
         "version" : "5.020003",
         "authorized" : true,
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.20.3-RC1",
         "author" : "SHAY",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.20.3-RC1.tar.bz2",
         "date" : "2015-08-22T22:12:34"
      },
      {
         "date" : "2015-08-20T15:36:45",
         "author" : "WOLFSAGE",
         "download_url" : "https://cpan.metacpan.org/authors/id/W/WO/WOLFSAGE/perl-5.23.2.tar.bz2",
         "name" : "perl-5.23.2",
         "status" : "cpan",
         "maturity" : "developer",
         "authorized" : true,
         "version" : "5.023002"
      },
      {
         "authorized" : true,
         "version" : "5.023001",
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.23.1",
         "download_url" : "https://cpan.metacpan.org/authors/id/W/WO/WOLFSAGE/perl-5.23.1.tar.bz2",
         "author" : "WOLFSAGE",
         "date" : "2015-07-20T19:26:31"
      },
      {
         "version" : "5.023000",
         "authorized" : true,
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.23.0",
         "date" : "2015-06-20T20:22:32",
         "author" : "RJBS",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.23.0.tar.bz2"
      },
      {
         "author" : "RJBS",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.22.0.tar.bz2",
         "date" : "2015-06-01T17:51:59",
         "version" : "5.022000",
         "authorized" : true,
         "status" : "cpan",
         "maturity" : "released",
         "name" : "perl-5.22.0"
      },
      {
         "author" : "RJBS",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.22.0-RC2.tar.bz2",
         "date" : "2015-05-21T23:03:22",
         "name" : "perl-5.22.0-RC2",
         "maturity" : "developer",
         "status" : "cpan",
         "authorized" : true,
         "version" : "5.022000"
      },
      {
         "date" : "2015-05-19T14:12:19",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.22.0-RC1.tar.bz2",
         "author" : "RJBS",
         "version" : "5.022000",
         "authorized" : true,
         "name" : "perl-5.22.0-RC1",
         "maturity" : "developer",
         "status" : "cpan"
      },
      {
         "authorized" : true,
         "version" : "5.021011",
         "name" : "perl-5.21.11",
         "maturity" : "developer",
         "status" : "cpan",
         "date" : "2015-04-20T21:28:37",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.21.11.tar.bz2",
         "author" : "SHAY"
      },
      {
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.21.10.tar.bz2",
         "author" : "SHAY",
         "date" : "2015-03-20T18:30:20",
         "version" : "5.021010",
         "authorized" : true,
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.21.10"
      },
      {
         "date" : "2015-02-21T05:27:09",
         "download_url" : "https://cpan.metacpan.org/authors/id/X/XS/XSAWYERX/perl-5.21.9.tar.bz2",
         "author" : "XSAWYERX",
         "name" : "perl-5.21.9",
         "maturity" : "developer",
         "status" : "backpan",
         "authorized" : true,
         "version" : "5.021009"
      },
      {
         "authorized" : true,
         "version" : "5.020002",
         "name" : "perl-5.20.2",
         "status" : "cpan",
         "maturity" : "released",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.20.2.tar.bz2",
         "author" : "SHAY",
         "date" : "2015-02-14T18:26:43"
      },
      {
         "date" : "2015-02-01T03:07:56",
         "author" : "SHAY",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.20.2-RC1.tar.bz2",
         "version" : "5.020002",
         "authorized" : true,
         "name" : "perl-5.20.2-RC1",
         "status" : "cpan",
         "maturity" : "developer"
      },
      {
         "date" : "2015-01-20T20:20:05",
         "download_url" : "https://cpan.metacpan.org/authors/id/W/WO/WOLFSAGE/perl-5.21.8.tar.bz2",
         "author" : "WOLFSAGE",
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.21.8",
         "version" : "5.021008",
         "authorized" : true
      },
      {
         "author" : "CORION",
         "download_url" : "https://cpan.metacpan.org/authors/id/C/CO/CORION/perl-5.21.7.tar.bz2",
         "date" : "2014-12-20T17:34:57",
         "name" : "perl-5.21.7",
         "maturity" : "developer",
         "status" : "cpan",
         "authorized" : true,
         "version" : "5.021007"
      },
      {
         "date" : "2014-11-20T23:39:06",
         "author" : "BINGOS",
         "download_url" : "https://cpan.metacpan.org/authors/id/B/BI/BINGOS/perl-5.21.6.tar.bz2",
         "authorized" : true,
         "version" : "5.021006",
         "name" : "perl-5.21.6",
         "maturity" : "developer",
         "status" : "cpan"
      },
      {
         "version" : "5.021005",
         "authorized" : true,
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.21.5",
         "date" : "2014-10-20T16:54:20",
         "download_url" : "https://cpan.metacpan.org/authors/id/A/AB/ABIGAIL/perl-5.21.5.tar.bz2",
         "author" : "ABIGAIL"
      },
      {
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.18.4.tar.bz2",
         "author" : "RJBS",
         "date" : "2014-10-02T00:48:31",
         "status" : "cpan",
         "maturity" : "released",
         "name" : "perl-5.18.4",
         "version" : "5.018004",
         "authorized" : true
      },
      {
         "version" : "5.018003",
         "authorized" : true,
         "status" : "cpan",
         "maturity" : "released",
         "name" : "perl-5.18.3",
         "date" : "2014-10-01T13:22:50",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.18.3.tar.bz2",
         "author" : "RJBS"
      },
      {
         "date" : "2014-09-27T12:54:08",
         "author" : "RJBS",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.18.3-RC2.tar.bz2",
         "version" : "5.018003",
         "authorized" : true,
         "name" : "perl-5.18.3-RC2",
         "maturity" : "developer",
         "status" : "cpan"
      },
      {
         "author" : "SHAY",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.21.4.tar.bz2",
         "date" : "2014-09-20T13:33:14",
         "name" : "perl-5.21.4",
         "status" : "cpan",
         "maturity" : "developer",
         "authorized" : true,
         "version" : "5.021004"
      },
      {
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.18.3-RC1.tar.bz2",
         "author" : "RJBS",
         "date" : "2014-09-17T20:29:53",
         "name" : "perl-5.18.3-RC1",
         "maturity" : "developer",
         "status" : "cpan",
         "authorized" : true,
         "version" : "5.018003"
      },
      {
         "authorized" : true,
         "version" : "5.020001",
         "maturity" : "released",
         "status" : "cpan",
         "name" : "perl-5.20.1",
         "date" : "2014-09-14T13:11:14",
         "author" : "SHAY",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.20.1.tar.bz2"
      },
      {
         "date" : "2014-09-07T17:01:11",
         "author" : "SHAY",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.20.1-RC2.tar.bz2",
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.20.1-RC2",
         "version" : "5.020001",
         "authorized" : true
      },
      {
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.20.1-RC1",
         "authorized" : true,
         "version" : "5.020001",
         "author" : "SHAY",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.20.1-RC1.tar.bz2",
         "date" : "2014-08-25T18:10:32"
      },
      {
         "version" : "5.021003",
         "authorized" : true,
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.21.3",
         "author" : "PCM",
         "download_url" : "https://cpan.metacpan.org/authors/id/P/PC/PCM/perl-5.21.3.tar.bz2",
         "date" : "2014-08-21T02:26:13"
      },
      {
         "author" : "ABIGAIL",
         "download_url" : "https://cpan.metacpan.org/authors/id/A/AB/ABIGAIL/perl-5.21.2.tar.bz2",
         "date" : "2014-07-20T13:48:02",
         "version" : "5.021002",
         "authorized" : true,
         "name" : "perl-5.21.2",
         "status" : "cpan",
         "maturity" : "developer"
      },
      {
         "download_url" : "https://cpan.metacpan.org/authors/id/W/WO/WOLFSAGE/perl-5.21.1.tar.bz2",
         "author" : "WOLFSAGE",
         "date" : "2014-06-20T15:31:10",
         "version" : "5.021001",
         "authorized" : true,
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.21.1"
      },
      {
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.21.0",
         "authorized" : true,
         "version" : "5.021000",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.21.0.tar.bz2",
         "author" : "RJBS",
         "date" : "2014-05-27T14:32:18"
      },
      {
         "version" : "5.020000",
         "authorized" : true,
         "name" : "perl-5.20.0",
         "maturity" : "released",
         "status" : "cpan",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.20.0.tar.bz2",
         "author" : "RJBS",
         "date" : "2014-05-27T01:35:13"
      },
      {
         "name" : "perl-5.20.0-RC1",
         "maturity" : "developer",
         "status" : "cpan",
         "version" : "5.020000",
         "authorized" : true,
         "date" : "2014-05-17T00:16:49",
         "author" : "RJBS",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.20.0-RC1.tar.bz2"
      },
      {
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.19.11",
         "version" : "5.019011",
         "authorized" : true,
         "date" : "2014-04-20T15:47:12",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.19.11.tar.bz2",
         "author" : "SHAY"
      },
      {
         "version" : "5.019010",
         "authorized" : true,
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.19.10",
         "date" : "2014-03-20T20:40:26",
         "author" : "ARC",
         "download_url" : "https://cpan.metacpan.org/authors/id/A/AR/ARC/perl-5.19.10.tar.bz2"
      },
      {
         "version" : "5.019009",
         "authorized" : true,
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.19.9",
         "download_url" : "https://cpan.metacpan.org/authors/id/T/TO/TONYC/perl-5.19.9.tar.bz2",
         "author" : "TONYC",
         "date" : "2014-02-20T04:24:45"
      },
      {
         "date" : "2014-01-20T21:59:04",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.19.8.tar.bz2",
         "author" : "RJBS",
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.19.8",
         "version" : "5.019008",
         "authorized" : true
      },
      {
         "maturity" : "released",
         "status" : "cpan",
         "name" : "perl-5.18.2",
         "version" : "5.018002",
         "authorized" : true,
         "date" : "2014-01-07T01:52:57",
         "author" : "RJBS",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.18.2.tar.bz2"
      },
      {
         "date" : "2013-12-22T03:30:43",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.18.2-RC4.tar.bz2",
         "author" : "RJBS",
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.18.2-RC4",
         "authorized" : true,
         "version" : "5.018002"
      },
      {
         "author" : "ABIGAIL",
         "download_url" : "https://cpan.metacpan.org/authors/id/A/AB/ABIGAIL/perl-5.19.7.tar.bz2",
         "date" : "2013-12-20T20:55:37",
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.19.7",
         "authorized" : true,
         "version" : "5.019007"
      },
      {
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.18.2-RC3.tar.bz2",
         "author" : "RJBS",
         "date" : "2013-12-19T21:27:42",
         "name" : "perl-5.18.2-RC3",
         "maturity" : "developer",
         "status" : "cpan",
         "authorized" : true,
         "version" : "5.018002"
      },
      {
         "author" : "RJBS",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.18.2-RC2.tar.bz2",
         "date" : "2013-12-07T13:55:43",
         "version" : "5.018002",
         "authorized" : true,
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.18.2-RC2"
      },
      {
         "authorized" : true,
         "version" : "5.018002",
         "name" : "perl-5.18.2-RC1",
         "status" : "cpan",
         "maturity" : "developer",
         "author" : "RJBS",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.18.2-RC1.tar.bz2",
         "date" : "2013-12-02T22:36:49"
      },
      {
         "download_url" : "https://cpan.metacpan.org/authors/id/B/BI/BINGOS/perl-5.19.6.tar.bz2",
         "author" : "BINGOS",
         "date" : "2013-11-20T20:37:20",
         "version" : "5.019006",
         "authorized" : true,
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.19.6"
      },
      {
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.19.5",
         "version" : "5.019005",
         "authorized" : true,
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.19.5.tar.bz2",
         "author" : "SHAY",
         "date" : "2013-10-20T13:25:55"
      },
      {
         "name" : "perl-5.19.4",
         "status" : "cpan",
         "maturity" : "developer",
         "authorized" : true,
         "version" : "5.019004",
         "author" : "SHAY",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.19.4.tar.bz2",
         "date" : "2013-09-20T15:58:20"
      },
      {
         "author" : "SHAY",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.19.3.tar.bz2",
         "date" : "2013-08-20T16:09:42",
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.19.3",
         "authorized" : true,
         "version" : "5.019003"
      },
      {
         "author" : "RJBS",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.18.1.tar.bz2",
         "date" : "2013-08-12T14:31:08",
         "maturity" : "released",
         "status" : "cpan",
         "name" : "perl-5.18.1",
         "authorized" : true,
         "version" : "5.018001"
      },
      {
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.18.1-RC3",
         "authorized" : true,
         "version" : "5.018001",
         "date" : "2013-08-09T02:28:00",
         "author" : "RJBS",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.18.1-RC3.tar.bz2"
      },
      {
         "authorized" : true,
         "version" : "5.018001",
         "name" : "perl-5.18.1-RC2",
         "status" : "cpan",
         "maturity" : "developer",
         "date" : "2013-08-04T12:34:33",
         "author" : "RJBS",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.18.1-RC2.tar.bz2"
      },
      {
         "date" : "2013-08-02T03:09:02",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.18.1-RC1.tar.bz2",
         "author" : "RJBS",
         "version" : "5.018001",
         "authorized" : true,
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.18.1-RC1"
      },
      {
         "download_url" : "https://cpan.metacpan.org/authors/id/A/AR/ARISTOTLE/perl-5.19.2.tar.bz2",
         "author" : "ARISTOTLE",
         "date" : "2013-07-22T05:59:35",
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.19.2",
         "version" : "5.019002",
         "authorized" : true
      },
      {
         "author" : "DAGOLDEN",
         "download_url" : "https://cpan.metacpan.org/authors/id/D/DA/DAGOLDEN/perl-5.19.1.tar.bz2",
         "date" : "2013-06-21T01:24:18",
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.19.1",
         "authorized" : true,
         "version" : "5.019001"
      },
      {
         "authorized" : true,
         "version" : "5.019000",
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.19.0",
         "author" : "RJBS",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.19.0.tar.bz2",
         "date" : "2013-05-20T13:12:38"
      },
      {
         "date" : "2013-05-18T13:33:49",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.18.0.tar.bz2",
         "author" : "RJBS",
         "version" : "5.018000",
         "authorized" : true,
         "status" : "cpan",
         "maturity" : "released",
         "name" : "perl-5.18.0"
      },
      {
         "author" : "RJBS",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.18.0-RC4.tar.bz2",
         "date" : "2013-05-16T02:53:44",
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.18.0-RC4",
         "version" : "5.018000",
         "authorized" : true
      },
      {
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.18.0-RC3.tar.bz2",
         "author" : "RJBS",
         "date" : "2013-05-14T01:32:05",
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.18.0-RC3",
         "authorized" : true,
         "version" : "5.018000"
      },
      {
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.18.0-RC2.tar.bz2",
         "author" : "RJBS",
         "date" : "2013-05-12T23:14:51",
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.18.0-RC2",
         "authorized" : true,
         "version" : "5.018000"
      },
      {
         "date" : "2013-05-11T12:29:53",
         "author" : "RJBS",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.18.0-RC1.tar.bz2",
         "name" : "perl-5.18.0-RC1",
         "status" : "cpan",
         "maturity" : "developer",
         "version" : "5.018000",
         "authorized" : true
      },
      {
         "version" : "5.017011",
         "authorized" : true,
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.17.11",
         "author" : "RJBS",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.17.11.tar.bz2",
         "date" : "2013-04-21T00:52:16"
      },
      {
         "version" : "5.017010",
         "authorized" : true,
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.17.10",
         "author" : "CORION",
         "download_url" : "https://cpan.metacpan.org/authors/id/C/CO/CORION/perl-5.17.10.tar.bz2",
         "date" : "2013-03-21T23:11:03"
      },
      {
         "date" : "2013-03-11T21:08:33",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.16.3.tar.bz2",
         "author" : "RJBS",
         "version" : "5.016003",
         "authorized" : true,
         "maturity" : "released",
         "status" : "cpan",
         "name" : "perl-5.16.3"
      },
      {
         "author" : "DAPM",
         "download_url" : "https://cpan.metacpan.org/authors/id/D/DA/DAPM/perl-5.14.4.tar.bz2",
         "date" : "2013-03-10T23:47:40",
         "name" : "perl-5.14.4",
         "maturity" : "released",
         "status" : "cpan",
         "version" : "5.014004",
         "authorized" : true
      },
      {
         "author" : "DAPM",
         "download_url" : "https://cpan.metacpan.org/authors/id/D/DA/DAPM/perl-5.14.4-RC2.tar.bz2",
         "date" : "2013-03-07T19:52:52",
         "authorized" : true,
         "version" : "5.014004",
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.14.4-RC2"
      },
      {
         "version" : "5.016003",
         "authorized" : true,
         "name" : "perl-5.16.3-RC1",
         "status" : "cpan",
         "maturity" : "developer",
         "author" : "RJBS",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.16.3-RC1.tar.bz2",
         "date" : "2013-03-07T16:03:14"
      },
      {
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.14.4-RC1",
         "version" : "5.014004",
         "authorized" : true,
         "date" : "2013-03-05T17:03:49",
         "download_url" : "https://cpan.metacpan.org/authors/id/D/DA/DAPM/perl-5.14.4-RC1.tar.bz2",
         "author" : "DAPM"
      },
      {
         "date" : "2013-02-20T22:21:02",
         "download_url" : "https://cpan.metacpan.org/authors/id/B/BI/BINGOS/perl-5.17.9.tar.bz2",
         "author" : "BINGOS",
         "name" : "perl-5.17.9",
         "status" : "cpan",
         "maturity" : "developer",
         "version" : "5.017009",
         "authorized" : true
      },
      {
         "date" : "2013-01-20T18:48:45",
         "download_url" : "https://cpan.metacpan.org/authors/id/A/AR/ARC/perl-5.17.8.tar.bz2",
         "author" : "ARC",
         "name" : "perl-5.17.8",
         "maturity" : "developer",
         "status" : "cpan",
         "authorized" : true,
         "version" : "5.017008"
      },
      {
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.17.7",
         "version" : "5.017007",
         "authorized" : true,
         "date" : "2012-12-18T21:50:28",
         "download_url" : "https://cpan.metacpan.org/authors/id/D/DR/DROLSKY/perl-5.17.7.tar.bz2",
         "author" : "DROLSKY"
      },
      {
         "version" : "5.017006",
         "authorized" : true,
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.17.6",
         "date" : "2012-11-21T00:08:12",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.17.6.tar.bz2",
         "author" : "RJBS"
      },
      {
         "maturity" : "released",
         "status" : "cpan",
         "name" : "perl-5.12.5",
         "version" : "5.012005",
         "authorized" : true,
         "download_url" : "https://cpan.metacpan.org/authors/id/D/DO/DOM/perl-5.12.5.tar.bz2",
         "author" : "DOM",
         "date" : "2012-11-10T14:02:17"
      },
      {
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.12.5-RC2",
         "version" : "5.012005",
         "authorized" : true,
         "author" : "DOM",
         "download_url" : "https://cpan.metacpan.org/authors/id/D/DO/DOM/perl-5.12.5-RC2.tar.bz2",
         "date" : "2012-11-08T21:12:17"
      },
      {
         "name" : "perl-5.12.5-RC1",
         "status" : "cpan",
         "maturity" : "developer",
         "authorized" : true,
         "version" : "5.012005",
         "author" : "DOM",
         "download_url" : "https://cpan.metacpan.org/authors/id/D/DO/DOM/perl-5.12.5-RC1.tar.bz2",
         "date" : "2012-11-03T17:27:59"
      },
      {
         "name" : "perl-5.16.2",
         "status" : "cpan",
         "maturity" : "released",
         "authorized" : true,
         "version" : "5.016002",
         "author" : "RJBS",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.16.2.tar.bz2",
         "date" : "2012-11-01T13:44:07"
      },
      {
         "authorized" : true,
         "version" : "5.016002",
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.16.2-RC1",
         "date" : "2012-10-27T01:23:09",
         "author" : "RJBS",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.16.2-RC1.tar.bz2"
      },
      {
         "version" : "5.017005",
         "authorized" : true,
         "name" : "perl-5.17.5",
         "status" : "cpan",
         "maturity" : "developer",
         "author" : "FLORA",
         "download_url" : "https://cpan.metacpan.org/authors/id/F/FL/FLORA/perl-5.17.5.tar.bz2",
         "date" : "2012-10-20T16:31:11"
      },
      {
         "maturity" : "released",
         "status" : "cpan",
         "name" : "perl-5.14.3",
         "version" : "5.014003",
         "authorized" : true,
         "date" : "2012-10-12T20:24:43",
         "author" : "DOM",
         "download_url" : "https://cpan.metacpan.org/authors/id/D/DO/DOM/perl-5.14.3.tar.bz2"
      },
      {
         "download_url" : "https://cpan.metacpan.org/authors/id/D/DO/DOM/perl-5.14.3-RC2.tar.bz2",
         "author" : "DOM",
         "date" : "2012-10-10T19:46:29",
         "version" : "5.014003",
         "authorized" : true,
         "name" : "perl-5.14.3-RC2",
         "status" : "cpan",
         "maturity" : "developer"
      },
      {
         "download_url" : "https://cpan.metacpan.org/authors/id/D/DO/DOM/perl-5.14.3-RC1.tar.bz2",
         "author" : "DOM",
         "date" : "2012-09-26T22:15:57",
         "authorized" : true,
         "version" : "5.014003",
         "name" : "perl-5.14.3-RC1",
         "maturity" : "developer",
         "status" : "cpan"
      },
      {
         "date" : "2012-09-20T00:40:48",
         "download_url" : "https://cpan.metacpan.org/authors/id/F/FL/FLORA/perl-5.17.4.tar.bz2",
         "author" : "FLORA",
         "authorized" : true,
         "version" : "5.017004",
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.17.4"
      },
      {
         "name" : "perl-5.17.3",
         "maturity" : "developer",
         "status" : "cpan",
         "authorized" : true,
         "version" : "5.017003",
         "author" : "SHAY",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.17.3.tar.bz2",
         "date" : "2012-08-20T14:12:28"
      },
      {
         "date" : "2012-08-08T22:30:11",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.16.1.tar.bz2",
         "author" : "RJBS",
         "authorized" : true,
         "version" : "5.016001",
         "name" : "perl-5.16.1",
         "maturity" : "released",
         "status" : "cpan"
      },
      {
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.16.1-RC1.tar.bz2",
         "author" : "RJBS",
         "date" : "2012-08-03T18:59:23",
         "version" : "5.016001",
         "authorized" : true,
         "name" : "perl-5.16.1-RC1",
         "status" : "cpan",
         "maturity" : "developer"
      },
      {
         "name" : "perl-5.17.2",
         "status" : "cpan",
         "maturity" : "developer",
         "version" : "5.017002",
         "authorized" : true,
         "download_url" : "https://cpan.metacpan.org/authors/id/T/TO/TONYC/perl-5.17.2.tar.bz2",
         "author" : "TONYC",
         "date" : "2012-07-20T14:27:59"
      },
      {
         "version" : "5.017001",
         "authorized" : true,
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.17.1",
         "date" : "2012-06-20T17:38:46",
         "download_url" : "https://cpan.metacpan.org/authors/id/D/DO/DOY/perl-5.17.1.tar.bz2",
         "author" : "DOY"
      },
      {
         "author" : "ZEFRAM",
         "download_url" : "https://cpan.metacpan.org/authors/id/Z/ZE/ZEFRAM/perl-5.17.0.tar.bz2",
         "date" : "2012-05-26T16:24:02",
         "name" : "perl-5.17.0",
         "status" : "cpan",
         "maturity" : "developer",
         "authorized" : true,
         "version" : "5.017000"
      },
      {
         "date" : "2012-05-20T22:51:12",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.16.0.tar.bz2",
         "author" : "RJBS",
         "version" : "5.016000",
         "authorized" : true,
         "maturity" : "released",
         "status" : "cpan",
         "name" : "perl-5.16.0"
      },
      {
         "version" : "5.016000",
         "authorized" : true,
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.16.0-RC2",
         "date" : "2012-05-16T03:22:59",
         "author" : "RJBS",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.16.0-RC2.tar.bz2"
      },
      {
         "author" : "RJBS",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.16.0-RC1.tar.bz2",
         "date" : "2012-05-15T02:51:48",
         "authorized" : true,
         "version" : "5.016000",
         "name" : "perl-5.16.0-RC1",
         "maturity" : "developer",
         "status" : "cpan"
      },
      {
         "date" : "2012-05-11T03:41:02",
         "author" : "RJBS",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.16.0-RC0.tar.bz2",
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.16.0-RC0",
         "version" : "5.016000",
         "authorized" : true
      },
      {
         "date" : "2012-03-20T19:01:29",
         "download_url" : "https://cpan.metacpan.org/authors/id/A/AB/ABIGAIL/perl-5.15.9.tar.bz2",
         "author" : "ABIGAIL",
         "name" : "perl-5.15.9",
         "maturity" : "developer",
         "status" : "cpan",
         "authorized" : true,
         "version" : "5.015009"
      },
      {
         "download_url" : "https://cpan.metacpan.org/authors/id/C/CO/CORION/perl-5.15.8.tar.bz2",
         "author" : "CORION",
         "date" : "2012-02-20T22:38:13",
         "authorized" : true,
         "version" : "5.015008",
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.15.8"
      },
      {
         "authorized" : true,
         "version" : "5.015007",
         "name" : "perl-5.15.7",
         "status" : "cpan",
         "maturity" : "developer",
         "date" : "2012-01-20T20:08:28",
         "author" : "BINGOS",
         "download_url" : "https://cpan.metacpan.org/authors/id/B/BI/BINGOS/perl-5.15.7.tar.bz2"
      },
      {
         "download_url" : "https://cpan.metacpan.org/authors/id/D/DR/DROLSKY/perl-5.15.6.tar.bz2",
         "author" : "DROLSKY",
         "date" : "2011-12-20T17:55:58",
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.15.6",
         "version" : "5.015006",
         "authorized" : true
      },
      {
         "name" : "perl-5.15.5",
         "maturity" : "developer",
         "status" : "cpan",
         "version" : "5.015005",
         "authorized" : true,
         "author" : "SHAY",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.15.5.tar.bz2",
         "date" : "2011-11-20T20:40:34"
      },
      {
         "date" : "2011-10-20T21:17:45",
         "download_url" : "https://cpan.metacpan.org/authors/id/F/FL/FLORA/perl-5.15.4.tar.bz2",
         "author" : "FLORA",
         "name" : "perl-5.15.4",
         "maturity" : "developer",
         "status" : "cpan",
         "version" : "5.015004",
         "authorized" : true
      },
      {
         "version" : "5.014002",
         "authorized" : true,
         "maturity" : "released",
         "status" : "cpan",
         "name" : "perl-5.14.2",
         "author" : "FLORA",
         "download_url" : "https://cpan.metacpan.org/authors/id/F/FL/FLORA/perl-5.14.2.tar.bz2",
         "date" : "2011-09-26T14:56:49"
      },
      {
         "author" : "STEVAN",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/ST/STEVAN/perl-5.15.3.tar.bz2",
         "date" : "2011-09-21T03:05:05",
         "authorized" : true,
         "version" : "5.015003",
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.15.3"
      },
      {
         "date" : "2011-09-19T11:25:31",
         "download_url" : "https://cpan.metacpan.org/authors/id/F/FL/FLORA/perl-5.14.2-RC1.tar.bz2",
         "author" : "FLORA",
         "name" : "perl-5.14.2-RC1",
         "maturity" : "developer",
         "status" : "cpan",
         "version" : "5.014002",
         "authorized" : true
      },
      {
         "date" : "2011-08-21T00:05:23",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.15.2.tar.bz2",
         "author" : "RJBS",
         "version" : "5.015002",
         "authorized" : true,
         "name" : "perl-5.15.2",
         "status" : "cpan",
         "maturity" : "developer"
      },
      {
         "version" : "5.015001",
         "authorized" : true,
         "name" : "perl-5.15.1",
         "status" : "cpan",
         "maturity" : "developer",
         "date" : "2011-07-20T21:15:08",
         "author" : "ZEFRAM",
         "download_url" : "https://cpan.metacpan.org/authors/id/Z/ZE/ZEFRAM/perl-5.15.1.tar.bz2"
      },
      {
         "download_url" : "https://cpan.metacpan.org/authors/id/D/DA/DAGOLDEN/perl-5.15.0.tar.bz2",
         "author" : "DAGOLDEN",
         "date" : "2011-06-20T23:19:05",
         "authorized" : true,
         "version" : "5.015000",
         "name" : "perl-5.15.0",
         "status" : "cpan",
         "maturity" : "developer"
      },
      {
         "name" : "perl-5.12.4",
         "maturity" : "released",
         "status" : "cpan",
         "version" : "5.012004",
         "authorized" : true,
         "author" : "LBROCARD",
         "download_url" : "https://cpan.metacpan.org/authors/id/L/LB/LBROCARD/perl-5.12.4.tar.bz2",
         "date" : "2011-06-20T10:41:26"
      },
      {
         "version" : "5.014001",
         "authorized" : true,
         "status" : "cpan",
         "maturity" : "released",
         "name" : "perl-5.14.1",
         "author" : "JESSE",
         "download_url" : "https://cpan.metacpan.org/authors/id/J/JE/JESSE/perl-5.14.1.tar.bz2",
         "date" : "2011-06-17T02:42:01"
      },
      {
         "version" : "5.012004",
         "authorized" : true,
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.12.4-RC2",
         "author" : "LBROCARD",
         "download_url" : "https://cpan.metacpan.org/authors/id/L/LB/LBROCARD/perl-5.12.4-RC2.tar.bz2",
         "date" : "2011-06-15T17:00:36"
      },
      {
         "version" : "5.014001",
         "authorized" : true,
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.14.1-RC1",
         "author" : "JESSE",
         "download_url" : "https://cpan.metacpan.org/authors/id/J/JE/JESSE/perl-5.14.1-RC1.tar.bz2",
         "date" : "2011-06-09T23:48:04"
      },
      {
         "author" : "LBROCARD",
         "download_url" : "https://cpan.metacpan.org/authors/id/L/LB/LBROCARD/perl-5.12.4-RC1.tar.bz2",
         "date" : "2011-06-08T13:19:36",
         "authorized" : true,
         "version" : "5.012004",
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.12.4-RC1"
      },
      {
         "status" : "cpan",
         "maturity" : "released",
         "name" : "perl-5.14.0",
         "version" : "5.014000",
         "authorized" : true,
         "download_url" : "https://cpan.metacpan.org/authors/id/J/JE/JESSE/perl-5.14.0.tar.bz2",
         "author" : "JESSE",
         "date" : "2011-05-14T20:34:05"
      },
      {
         "download_url" : "https://cpan.metacpan.org/authors/id/J/JE/JESSE/perl-5.14.0-RC3.tar.bz2",
         "author" : "JESSE",
         "date" : "2011-05-11T15:49:42",
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.14.0-RC3",
         "version" : "5.014000",
         "authorized" : true
      },
      {
         "download_url" : "https://cpan.metacpan.org/authors/id/J/JE/JESSE/perl-5.14.0-RC2.tar.bz2",
         "author" : "JESSE",
         "date" : "2011-05-04T16:42:27",
         "name" : "perl-5.14.0-RC2",
         "maturity" : "developer",
         "status" : "cpan",
         "authorized" : true,
         "version" : "5.014000"
      },
      {
         "name" : "perl-5.14.0-RC1",
         "maturity" : "developer",
         "status" : "cpan",
         "version" : "5.014000",
         "authorized" : true,
         "date" : "2011-04-20T11:53:32",
         "author" : "JESSE",
         "download_url" : "https://cpan.metacpan.org/authors/id/J/JE/JESSE/perl-5.14.0-RC1.tar.bz2"
      },
      {
         "authorized" : true,
         "version" : "5.013011",
         "name" : "perl-5.13.11",
         "maturity" : "developer",
         "status" : "cpan",
         "date" : "2011-03-20T19:49:16",
         "download_url" : "https://cpan.metacpan.org/authors/id/F/FL/FLORA/perl-5.13.11.tar.bz2",
         "author" : "FLORA"
      },
      {
         "name" : "perl-5.13.10",
         "status" : "cpan",
         "maturity" : "developer",
         "version" : "5.013010",
         "authorized" : true,
         "download_url" : "https://cpan.metacpan.org/authors/id/A/AV/AVAR/perl-5.13.10.tar.bz2",
         "author" : "AVAR",
         "date" : "2011-02-20T19:18:02"
      },
      {
         "maturity" : "released",
         "status" : "cpan",
         "name" : "perl-5.12.3",
         "authorized" : true,
         "version" : "5.012003",
         "date" : "2011-01-22T03:35:35",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.12.3.tar.bz2",
         "author" : "RJBS"
      },
      {
         "download_url" : "https://cpan.metacpan.org/authors/id/J/JE/JESSE/perl-5.13.9.tar.bz2",
         "author" : "JESSE",
         "date" : "2011-01-21T01:42:07",
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.13.9",
         "authorized" : true,
         "version" : "5.013009"
      },
      {
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.12.3-RC3",
         "authorized" : true,
         "version" : "5.012003",
         "author" : "RJBS",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.12.3-RC3.tar.bz2",
         "date" : "2011-01-18T02:13:17"
      },
      {
         "name" : "perl-5.12.3-RC2",
         "maturity" : "developer",
         "status" : "cpan",
         "authorized" : true,
         "version" : "5.012003",
         "date" : "2011-01-15T04:05:30",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.12.3-RC2.tar.bz2",
         "author" : "RJBS"
      },
      {
         "date" : "2011-01-10T02:12:53",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.12.3-RC1.tar.bz2",
         "author" : "RJBS",
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.12.3-RC1",
         "version" : "5.012003",
         "authorized" : true
      },
      {
         "date" : "2010-12-19T23:06:25",
         "download_url" : "https://cpan.metacpan.org/authors/id/Z/ZE/ZEFRAM/perl-5.13.8.tar.bz2",
         "author" : "ZEFRAM",
         "name" : "perl-5.13.8",
         "status" : "cpan",
         "maturity" : "developer",
         "authorized" : true,
         "version" : "5.013008"
      },
      {
         "authorized" : true,
         "version" : "5.013007",
         "name" : "perl-5.13.7",
         "maturity" : "developer",
         "status" : "cpan",
         "date" : "2010-11-21T01:14:06",
         "download_url" : "https://cpan.metacpan.org/authors/id/B/BI/BINGOS/perl-5.13.7.tar.bz2",
         "author" : "BINGOS"
      },
      {
         "authorized" : true,
         "version" : "5.013006",
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.13.6",
         "date" : "2010-10-21T01:41:01",
         "download_url" : "https://cpan.metacpan.org/authors/id/M/MI/MIYAGAWA/perl-5.13.6.tar.bz2",
         "author" : "MIYAGAWA"
      },
      {
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.13.5",
         "authorized" : true,
         "version" : "5.013005",
         "date" : "2010-09-19T21:22:47",
         "author" : "SHAY",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.13.5.tar.bz2"
      },
      {
         "version" : "5.012002",
         "authorized" : true,
         "maturity" : "released",
         "status" : "cpan",
         "name" : "perl-5.12.2",
         "date" : "2010-09-07T01:41:31",
         "download_url" : "https://cpan.metacpan.org/authors/id/J/JE/JESSE/perl-5.12.2.tar.bz2",
         "author" : "JESSE"
      },
      {
         "download_url" : "https://cpan.metacpan.org/authors/id/J/JE/JESSE/perl-5.12.2-RC1.tar.bz2",
         "author" : "JESSE",
         "date" : "2010-08-31T16:48:01",
         "authorized" : true,
         "version" : "5.012002",
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.12.2-RC1"
      },
      {
         "author" : "FLORA",
         "download_url" : "https://cpan.metacpan.org/authors/id/F/FL/FLORA/perl-5.13.4.tar.bz2",
         "date" : "2010-08-20T15:39:07",
         "version" : "5.013004",
         "authorized" : true,
         "name" : "perl-5.13.4",
         "status" : "cpan",
         "maturity" : "developer"
      },
      {
         "authorized" : true,
         "version" : "5.013003",
         "name" : "perl-5.13.3",
         "status" : "cpan",
         "maturity" : "developer",
         "date" : "2010-07-20T10:23:23",
         "author" : "DAGOLDEN",
         "download_url" : "https://cpan.metacpan.org/authors/id/D/DA/DAGOLDEN/perl-5.13.3.tar.bz2"
      },
      {
         "date" : "2010-06-22T21:39:26",
         "author" : "MSTROUT",
         "download_url" : "https://cpan.metacpan.org/authors/id/M/MS/MSTROUT/perl-5.13.2.tar.bz2",
         "authorized" : true,
         "version" : "5.013002",
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.13.2"
      },
      {
         "author" : "RJBS",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.13.1.tar.bz2",
         "date" : "2010-05-20T14:03:45",
         "version" : "5.013001",
         "authorized" : true,
         "name" : "perl-5.13.1",
         "maturity" : "developer",
         "status" : "cpan"
      },
      {
         "name" : "perl-5.12.1",
         "status" : "cpan",
         "maturity" : "released",
         "authorized" : true,
         "version" : "5.012001",
         "author" : "JESSE",
         "download_url" : "https://cpan.metacpan.org/authors/id/J/JE/JESSE/perl-5.12.1.tar.bz2",
         "date" : "2010-05-16T22:40:16"
      },
      {
         "date" : "2010-05-13T22:31:41",
         "author" : "JESSE",
         "download_url" : "https://cpan.metacpan.org/authors/id/J/JE/JESSE/perl-5.12.1-RC2.tar.bz2",
         "name" : "perl-5.12.1-RC2",
         "status" : "cpan",
         "maturity" : "developer",
         "version" : "5.012001",
         "authorized" : true
      },
      {
         "authorized" : true,
         "version" : "5.012001",
         "name" : "perl-5.12.1-RC1",
         "status" : "cpan",
         "maturity" : "developer",
         "date" : "2010-05-10T02:43:48",
         "author" : "JESSE",
         "download_url" : "https://cpan.metacpan.org/authors/id/J/JE/JESSE/perl-5.12.1-RC1.tar.bz2"
      },
      {
         "name" : "perl-5.13.0",
         "status" : "cpan",
         "maturity" : "developer",
         "version" : "5.013000",
         "authorized" : true,
         "date" : "2010-04-20T20:06:02",
         "author" : "LBROCARD",
         "download_url" : "https://cpan.metacpan.org/authors/id/L/LB/LBROCARD/perl-5.13.0.tar.bz2"
      },
      {
         "version" : "5.012000",
         "authorized" : true,
         "status" : "cpan",
         "maturity" : "released",
         "name" : "perl-5.12.0",
         "date" : "2010-04-12T22:38:37",
         "download_url" : "https://cpan.metacpan.org/authors/id/J/JE/JESSE/perl-5.12.0.tar.bz2",
         "author" : "JESSE"
      },
      {
         "date" : "2010-04-10T03:46:04",
         "download_url" : "https://cpan.metacpan.org/authors/id/J/JE/JESSE/perl-5.12.0-RC5.tar.bz2",
         "author" : "JESSE",
         "name" : "perl-5.12.0-RC5",
         "maturity" : "developer",
         "status" : "cpan",
         "authorized" : true,
         "version" : "5.012000"
      },
      {
         "download_url" : "https://cpan.metacpan.org/authors/id/J/JE/JESSE/perl-5.12.0-RC4.tar.bz2",
         "author" : "JESSE",
         "date" : "2010-04-07T05:39:46",
         "version" : "5.012000",
         "authorized" : true,
         "name" : "perl-5.12.0-RC4",
         "status" : "cpan",
         "maturity" : "developer"
      },
      {
         "download_url" : "https://cpan.metacpan.org/authors/id/J/JE/JESSE/perl-5.12.0-RC3.tar.bz2",
         "author" : "JESSE",
         "date" : "2010-04-03T02:40:48",
         "version" : "5.012000",
         "authorized" : true,
         "name" : "perl-5.12.0-RC3",
         "status" : "cpan",
         "maturity" : "developer"
      },
      {
         "authorized" : true,
         "version" : "5.012000",
         "name" : "perl-5.12.0-RC2",
         "maturity" : "developer",
         "status" : "cpan",
         "download_url" : "https://cpan.metacpan.org/authors/id/J/JE/JESSE/perl-5.12.0-RC2.tar.bz2",
         "author" : "JESSE",
         "date" : "2010-04-01T02:38:12"
      },
      {
         "date" : "2010-03-29T18:29:49",
         "author" : "JESSE",
         "download_url" : "https://cpan.metacpan.org/authors/id/J/JE/JESSE/perl-5.12.0-RC1.tar.bz2",
         "name" : "perl-5.12.0-RC1",
         "status" : "cpan",
         "maturity" : "developer",
         "authorized" : true,
         "version" : "5.012000"
      },
      {
         "author" : "JESSE",
         "download_url" : "https://cpan.metacpan.org/authors/id/J/JE/JESSE/perl-5.12.0-RC0.tar.gz",
         "date" : "2010-03-21T20:41:11",
         "status" : "backpan",
         "maturity" : "developer",
         "name" : "perl-5.12.0-RC0",
         "authorized" : true,
         "version" : "5.012000"
      },
      {
         "date" : "2010-02-21T00:45:26",
         "download_url" : "https://cpan.metacpan.org/authors/id/S/SH/SHAY/perl-5.11.5.tar.bz2",
         "author" : "SHAY",
         "authorized" : true,
         "version" : "5.011005",
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.11.5"
      },
      {
         "date" : "2010-01-20T16:48:28",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/perl-5.11.4.tar.bz2",
         "author" : "RJBS",
         "authorized" : true,
         "version" : "5.011004",
         "name" : "perl-5.11.4",
         "status" : "cpan",
         "maturity" : "developer"
      },
      {
         "date" : "2009-12-21T04:49:14",
         "download_url" : "https://cpan.metacpan.org/authors/id/J/JE/JESSE/perl-5.11.3.tar.bz2",
         "author" : "JESSE",
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.11.3",
         "version" : "5.011003",
         "authorized" : true
      },
      {
         "date" : "2009-11-20T07:20:52",
         "author" : "LBROCARD",
         "download_url" : "https://cpan.metacpan.org/authors/id/L/LB/LBROCARD/perl-5.11.2.tar.bz2",
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.11.2",
         "authorized" : true,
         "version" : "5.011002"
      },
      {
         "date" : "2009-10-20T17:51:38",
         "download_url" : "https://cpan.metacpan.org/authors/id/J/JE/JESSE/perl-5.11.1.tar.bz2",
         "author" : "JESSE",
         "authorized" : true,
         "version" : "5.011001",
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.11.1"
      },
      {
         "date" : "2009-10-02T20:51:46",
         "download_url" : "https://cpan.metacpan.org/authors/id/J/JE/JESSE/perl-5.11.0.tar.bz2",
         "author" : "JESSE",
         "version" : "5.011000",
         "authorized" : true,
         "name" : "perl-5.11.0",
         "status" : "cpan",
         "maturity" : "developer"
      },
      {
         "version" : "5.010001",
         "authorized" : true,
         "name" : "perl-5.10.1",
         "maturity" : "released",
         "status" : "cpan",
         "date" : "2009-08-23T14:21:38",
         "download_url" : "https://cpan.metacpan.org/authors/id/D/DA/DAPM/perl-5.10.1.tar.bz2",
         "author" : "DAPM"
      },
      {
         "author" : "DAPM",
         "download_url" : "https://cpan.metacpan.org/authors/id/D/DA/DAPM/perl-5.10.1-RC2.tar.bz2",
         "date" : "2009-08-18T23:45:03",
         "authorized" : true,
         "version" : "5.010001",
         "name" : "perl-5.10.1-RC2",
         "maturity" : "developer",
         "status" : "cpan"
      },
      {
         "date" : "2009-08-06T16:11:03",
         "download_url" : "https://cpan.metacpan.org/authors/id/D/DA/DAPM/perl-5.10.1-RC1.tar.bz2",
         "author" : "DAPM",
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.10.1-RC1",
         "authorized" : true,
         "version" : "5.010001"
      },
      {
         "date" : "2008-12-14T23:08:28",
         "download_url" : "https://cpan.metacpan.org/authors/id/N/NW/NWCLARK/perl-5.8.9.tar.bz2",
         "author" : "NWCLARK",
         "authorized" : true,
         "version" : "5.008009",
         "name" : "perl-5.8.9",
         "status" : "cpan",
         "maturity" : "released"
      },
      {
         "name" : "perl-5.8.9-RC2",
         "status" : "cpan",
         "maturity" : "developer",
         "version" : "5.008009",
         "authorized" : true,
         "date" : "2008-12-06T22:50:35",
         "author" : "NWCLARK",
         "download_url" : "https://cpan.metacpan.org/authors/id/N/NW/NWCLARK/perl-5.8.9-RC2.tar.bz2"
      },
      {
         "version" : "5.008009",
         "authorized" : true,
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.8.9-RC1",
         "author" : "NWCLARK",
         "download_url" : "https://cpan.metacpan.org/authors/id/N/NW/NWCLARK/perl-5.8.9-RC1.tar.bz2",
         "date" : "2008-11-10T23:14:59"
      },
      {
         "name" : "perl-5.10.0",
         "maturity" : "released",
         "status" : "cpan",
         "version" : "5.010000",
         "authorized" : true,
         "date" : "2007-12-18T17:41:41",
         "author" : "RGARCIA",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RG/RGARCIA/perl-5.10.0.tar.gz"
      },
      {
         "version" : "5.010000",
         "authorized" : true,
         "name" : "perl-5.10.0-RC2",
         "maturity" : "developer",
         "status" : "backpan",
         "date" : "2007-11-25T18:22:18",
         "author" : "RGARCIA",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RG/RGARCIA/perl-5.10.0-RC2.tar.gz"
      },
      {
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RG/RGARCIA/perl-5.10.0-RC1.tar.gz",
         "author" : "RGARCIA",
         "date" : "2007-11-17T15:31:20",
         "maturity" : "developer",
         "status" : "backpan",
         "name" : "perl-5.10.0-RC1",
         "version" : "5.009005",
         "authorized" : true
      },
      {
         "date" : "2007-07-07T16:13:57",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RG/RGARCIA/perl-5.9.5.tar.gz",
         "author" : "RGARCIA",
         "authorized" : true,
         "version" : "5.009005",
         "name" : "perl-5.9.5",
         "maturity" : "developer",
         "status" : "cpan"
      },
      {
         "name" : "perl-0.0017",
         "maturity" : "developer",
         "status" : "backpan",
         "authorized" : true,
         "version" : "0.0017",
         "date" : "2007-05-01T10:37:34",
         "download_url" : "https://cpan.metacpan.org/authors/id/H/HO/HOOO/perl-0.0017.tar.gz",
         "author" : "HOOO"
      },
      {
         "authorized" : true,
         "version" : "5.009004",
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.9.4",
         "author" : "RGARCIA",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RG/RGARCIA/perl-5.9.4.tar.gz",
         "date" : "2006-08-15T13:48:30"
      },
      {
         "date" : "2006-02-01T00:00:59",
         "author" : "NWCLARK",
         "download_url" : "https://cpan.metacpan.org/authors/id/N/NW/NWCLARK/perl-5.8.8.tar.bz2",
         "authorized" : true,
         "version" : "5.008008",
         "status" : "cpan",
         "maturity" : "released",
         "name" : "perl-5.8.8"
      },
      {
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.9.3",
         "version" : "5.009003",
         "authorized" : true,
         "date" : "2006-01-28T11:11:38",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RG/RGARCIA/perl-5.9.3.tar.gz",
         "author" : "RGARCIA"
      },
      {
         "author" : "NWCLARK",
         "download_url" : "https://cpan.metacpan.org/authors/id/N/NW/NWCLARK/perl-5.8.8-RC1.tar.bz2",
         "date" : "2006-01-20T10:09:18",
         "authorized" : true,
         "version" : "5.008008",
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.8.8-RC1"
      },
      {
         "author" : "NWCLARK",
         "download_url" : "https://cpan.metacpan.org/authors/id/N/NW/NWCLARK/perl-5.8.7.tar.bz2",
         "date" : "2005-05-30T22:19:23",
         "name" : "perl-5.8.7",
         "maturity" : "released",
         "status" : "cpan",
         "authorized" : true,
         "version" : "5.008007"
      },
      {
         "download_url" : "https://cpan.metacpan.org/authors/id/N/NW/NWCLARK/perl-5.8.7-RC1.tar.bz2",
         "author" : "NWCLARK",
         "date" : "2005-05-18T16:35:37",
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.8.7-RC1",
         "version" : "5.008007",
         "authorized" : true
      },
      {
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RG/RGARCIA/perl-5.9.2.tar.gz",
         "author" : "RGARCIA",
         "date" : "2005-04-01T09:53:24",
         "name" : "perl-5.9.2",
         "maturity" : "developer",
         "status" : "cpan",
         "authorized" : true,
         "version" : "5.009002"
      },
      {
         "version" : "5.008006",
         "authorized" : true,
         "maturity" : "released",
         "status" : "cpan",
         "name" : "perl-5.8.6",
         "download_url" : "https://cpan.metacpan.org/authors/id/N/NW/NWCLARK/perl-5.8.6.tar.bz2",
         "author" : "NWCLARK",
         "date" : "2004-11-27T23:56:17"
      },
      {
         "date" : "2004-11-11T19:56:33",
         "author" : "NWCLARK",
         "download_url" : "https://cpan.metacpan.org/authors/id/N/NW/NWCLARK/perl-5.8.6-RC1.tar.bz2",
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.8.6-RC1",
         "version" : "5.008006",
         "authorized" : true
      },
      {
         "name" : "perl-5.8.5",
         "maturity" : "released",
         "status" : "cpan",
         "authorized" : true,
         "version" : "5.008005",
         "download_url" : "https://cpan.metacpan.org/authors/id/N/NW/NWCLARK/perl-5.8.5.tar.bz2",
         "author" : "NWCLARK",
         "date" : "2004-07-19T21:56:20"
      },
      {
         "authorized" : true,
         "version" : "5.008005",
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.8.5-RC2",
         "author" : "NWCLARK",
         "download_url" : "https://cpan.metacpan.org/authors/id/N/NW/NWCLARK/perl-5.8.5-RC2.tar.bz2",
         "date" : "2004-07-08T21:55:05"
      },
      {
         "authorized" : true,
         "version" : "5.008005",
         "name" : "perl-5.8.5-RC1",
         "status" : "cpan",
         "maturity" : "developer",
         "date" : "2004-07-06T21:41:21",
         "author" : "NWCLARK",
         "download_url" : "https://cpan.metacpan.org/authors/id/N/NW/NWCLARK/perl-5.8.5-RC1.tar.bz2"
      },
      {
         "authorized" : true,
         "version" : "5.008003",
         "maturity" : "released",
         "status" : "cpan",
         "name" : "perl-5.8.4",
         "download_url" : "https://cpan.metacpan.org/authors/id/N/NW/NWCLARK/perl-5.8.4.tar.bz2",
         "author" : "NWCLARK",
         "date" : "2004-04-21T23:03:10"
      },
      {
         "download_url" : "https://cpan.metacpan.org/authors/id/N/NW/NWCLARK/perl-5.8.4-RC2.tar.bz2",
         "author" : "NWCLARK",
         "date" : "2004-04-15T22:59:51",
         "version" : "5.008003",
         "authorized" : true,
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.8.4-RC2"
      },
      {
         "download_url" : "https://cpan.metacpan.org/authors/id/N/NW/NWCLARK/perl-5.8.4-RC1.tar.bz2",
         "author" : "NWCLARK",
         "date" : "2004-04-05T21:27:48",
         "version" : "5.008003",
         "authorized" : true,
         "maturity" : "developer",
         "status" : "cpan",
         "name" : "perl-5.8.4-RC1"
      },
      {
         "status" : "cpan",
         "maturity" : "developer",
         "name" : "perl-5.9.1",
         "version" : "5.009001",
         "authorized" : true,
         "author" : "RGARCIA",
         "download_url" : "https://cpan.metacpan.org/authors/id/R/RG/RGARCIA/perl-5.9.1.tar.gz",
         "date" : "2004-03-16T19:35:25"
      },
      {
         "date" : "2004-02-23T14:02:10",
         "author" : "LBROCARD",
         "download_url" : "https://cpan.metacpan.org/authors/id/L/LB/LBROCARD/perl5.005_04.tar.gz",
         "status" : "cpan",
         "maturity" : "released",
         "name" : "perl5.005_04",
         "authorized" : true,
         "version" : "5.005"
      },
      {
         "name" : "perl5.005_04-RC2",
         "maturity" : "developer",
         "status" : "backpan",
         "authorized" : true,
         "version" : "5.005",
         "download_url" : "https://cpan.metacpan.org/authors/id/L/LB/LBROCARD/perl5.005_04-RC2.tar.gz",
         "author" : "LBROCARD",
         "date" : "2004-02-18T14:20:15"
      }
   ],
   "took" : 30,
   "total" : 418
}
EOF
}
