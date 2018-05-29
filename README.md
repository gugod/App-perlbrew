# NAME

[App::perlbrew](https://metacpan.org/pod/App::perlbrew) - Manage perl installations in your `$HOME`

## SYNOPSIS

```bash
# Installation
curl -L https://install.perlbrew.pl | bash

# Initialize
perlbrew init

# See what is available
perlbrew available

# Install some Perls
perlbrew install 5.18.2
perlbrew install perl-5.8.1
perlbrew install perl-5.19.9

# Install with thread support
perlbrew install -v perl-5.18.2 -Dusethreads

# See what were installed
perlbrew list

# Switch to an installation and set it as default
perlbrew switch perl-5.18.2

# Temporarily use another version only in current shell.
perlbrew use perl-5.8.1
perl -v

# Or turn it off completely. Useful when you messed up too deep.
# Or want to go back to the system Perl.
perlbrew off

# Use 'switch' command to turn it back on.
perlbrew switch perl-5.12.2

# Exec something with all perlbrew-ed perls
perlbrew exec -- perl -E 'say $]'
```

## DESCRIPTION

[perlbrew](https://metacpan.org/pod/perlbrew) is a program to automate the building and installation of perl in an
easy way. It provides multiple isolated perl environments, and a mechanism
for you to switch between them.

Everything is installed under `~/perl5/perlbrew`. You then need to include a
bashrc/cshrc provided by perlbrew to tweak the PATH for you. You then can
benefit from not having to run `sudo` commands to install
cpan modules because those are installed inside your `HOME` too.

For the documentation of perlbrew usage see [perlbrew](https://metacpan.org/pod/perlbrew) command
on [MetaCPAN](https://metacpan.org/), or by running `perlbrew help`,
or by visiting [perlbrew's official website](https://perlbrew.pl/). The following documentation
features the API of `App::perlbrew` module, and may not be remotely
close to what your want to read.

## INSTALLATION

It is the simplest to use the perlbrew installer, just paste this statement to
your terminal:

    curl -L https://install.perlbrew.pl | bash

Or this one, if you have `fetch` (default on FreeBSD):

    fetch -o- https://install.perlbrew.pl | sh

After that, `perlbrew` installs itself to `~/perl5/perlbrew/bin`, and you
should follow the instruction on screen to modify your shell rc file to put it
in your PATH.

The installed perlbrew command is a standalone executable that can be run with
system perl. The minimum system perl version requirement is 5.8.0, which should
be good enough for most of the OSes these days.

A fat-packed version of [patchperl](https://metacpan.org/pod/patchperl) is also installed to
`~/perl5/perlbrew/bin`, which is required to build old perls.

The directory `~/perl5/perlbrew` will contain all install perl executables,
libraries, documentations, lib, site\_libs. In the documentation, that directory
is referred as `perlbrew root`. If you need to set it to somewhere else because,
say, your `HOME` has limited quota, you can do that by setting `PERLBREW_ROOT`
environment variable before running the installer:

    export PERLBREW_ROOT=/opt/perl5
    curl -L https://install.perlbrew.pl | bash

As a result, different users on the same machine can all share the same perlbrew
root directory (although only original user that made the installation would
have the permission to perform perl installations.)

You may also install perlbrew from CPAN:

    cpan App::perlbrew

In this case, the perlbrew command is installed as `/usr/bin/perlbrew` or
`/usr/local/bin/perlbrew` or others, depending on the location of your system
perl installation.

Please make sure not to run this with one of the perls brewed with
perlbrew. It's the best to turn perlbrew off before you run that, if you're
upgrading.

    perlbrew off
    cpan App::perlbrew

You should always use system cpan (like /usr/bin/cpan) to install
`App::perlbrew` because it will be installed under a system PATH like
`/usr/bin`, which is not affected by perlbrew `switch` or `use` command.

The `self-upgrade` command will not upgrade the perlbrew installed by cpan
command, but it is also easy to upgrade perlbrew by running `cpan App::perlbrew`
again.

## METHODS

- (Str) current\_perl

    Return the "current perl" object attribute string, or, if absent, the value of
    `PERLBREW_PERL` environment variable.

- (Str) current\_perl (Str)

    Set the `current_perl` object attribute to the given value.

## PROJECT DEVELOPMENT

[perlbrew project](https://perlbrew.pl/) uses github
[https://github.com/gugod/App-perlbrew/issues](https://github.com/gugod/App-perlbrew/issues) and RT
<https://rt.cpan.org/Dist/Display.html?Queue=App-perlbrew> for issue
tracking. Issues sent to these two systems will eventually be reviewed
and handled.

See [https://github.com/gugod/App-perlbrew/contributors](https://github.com/gugod/App-perlbrew/contributors) for a list
of project contributors.

# AUTHOR

Kang-min Liu  `<gugod@gugod.org>`

# COPYRIGHT

Copyright (c) 2010-2016 Kang-min Liu `<gugod@gugod.org>`.

### LICENCE

The MIT License

## DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
