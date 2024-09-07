=begin yada yada

Copy this snippet to the beginning of tests that use Test2:

    use FindBin;
    use lib $FindBin::Bin;
    use App::perlbrew;
    require 'test2_helpers.pl';

tldr: This file should be `require`-ed after the "use App::perlbrew;" statement in
the test. It is meant to override subroutines for testing purposes and not
mess up developer's own perlbrew environment. `FindBin` should be used to
put 't/' dir to `@INC`.

=cut

use Test2::V0;
use Test2::Plugin::IOEvents;
use File::Temp qw( tempdir );

use App::Perlbrew::Path;
use App::Perlbrew::Path::Root;

use PerlbrewTestHelpers qw(write_file);

no warnings 'redefine';
sub dir {
    App::Perlbrew::Path->new(@_);
}

sub file {
    App::Perlbrew::Path->new(@_);
}

$App::perlbrew::PERLBREW_ROOT = tempdir( CLEANUP => 1 );
$App::perlbrew::PERLBREW_HOME = tempdir( CLEANUP => 1 );
$ENV{PERLBREW_ROOT} = $App::perlbrew::PERLBREW_ROOT;

delete $ENV{PERLBREW_LIB};
delete $ENV{PERLBREW_PERL};
delete $ENV{PERLBREW_PATH};
delete $ENV{PERLBREW_MANPATH};
delete $ENV{PERL_LOCAL_LIB_ROOT};

my $root = App::Perlbrew::Path::Root->new ($ENV{PERLBREW_ROOT});
$root->perls->mkpath;
$root->build->mkpath;
$root->dists->mkpath;

no warnings 'redefine';

sub App::perlbrew::do_install_release {
    my ($self, $name) = @_;

    $name = $self->{as} if $self->{as};

    my $root = $self->root;
    my $installation_dir = $root->perls ($name);

    $self->{installation_name} = $name;

    $installation_dir->mkpath;
    $root->perls($name, "bin")->mkpath;

    my $perl = $root->perls ($name, "bin")->child ("perl");
    write_file($perl, <<'CODE');
#!/usr/bin/env perl
use File::Basename;
my $name = basename(dirname(dirname($0))), "\n";
$name =~ s/^perl-//;
my ($a,$b,$c) = split /\./, $name;
printf('%d.%03d%03d' . "\n", $a, $b, $c);
CODE

    chmod 0755, $perl;

    note "(mock) installed $name to $installation_dir";
}

sub mock_perlbrew_install {
    my ($name, @args) = @_;
    App::perlbrew->new(install => $name, @args)->run();
}

sub mock_perlbrew_off {
    mock_perlbrew_use("");
}

sub mock_perlbrew_use {
    my ($name) = @_;

    my %env = App::perlbrew->new()->perlbrew_env($name);

    for my $k (qw< PERLBREW_PERL PERLBREW_LIB PERLBREW_PATH PERL5LIB >) {
        if (defined $env{$k}) {
            $ENV{$k} = $env{$k};
        } else {
            delete $ENV{$k}
        }
    }
}

sub mock_perlbrew_lib_create {
    my $name = shift;
    App::Perlbrew::Path->new($App::perlbrew::PERLBREW_HOME, "libs", $name)->mkpath;
}

# Wrappers around Test2::Tools::Mock, a replacement of Test::Spec, more or less.

sub mocked {
    my ($object, $cb) = @_;
    my $mocked = Mocked->new($object);

    if (defined($cb)) {
        $cb->($mocked, $object);
        $mocked->verify;
    } else {
        return $mocked;
    }
}

package Mocked; {
    use Test2::Tools::Mock qw(mock);

    sub new {
        my ($class, $object) = @_;
        return bless {
            object => $object,
            methods => [],
            mock => mock($object),
        }, $class
    }

    sub stubs {
        my ($self, $stubs) = @_;
        for my $k (keys %$stubs) {
            my $v = $stubs->{$k};
            if (ref($v) eq 'CODE') {
                $self->{mock}->override($k => $v);
            } else {
                $self->{mock}->override($k => sub { $v });
            }
        }
    }

    sub expects {
        my ($self, $method) = @_;
        my $mockedMethod = MockedMethod->new($self, $method);
        push @{$self->{methods}}, $mockedMethod;
        return $mockedMethod;
    }

    sub verify {
        my ($self) = @_;
        for (@{$self->{methods}}) {
            $_->verify();
        }
    }

    sub reset {
        my ($self) = @_;
        $self->{mock}->reset_all;
        $self->{methods} = [];
    }
}

package MockedMethod; {
    use Test2::Tools::Basic qw(ok note);
    use Test2::Tools::Compare qw(is);
    use Test2::Tools::Mock qw(mock);

    sub new {
        my ($class, $mocked, $method) = @_;
        my $self = bless {
            called => 0,
            with => undef,
            called_with => undef,
            at_least => undef,
            exactly => undef,
            method => $method,
            call_through => 1,
            returns => undef,
            mocked => $mocked,
        }, $class;
        $mocked->{mock}->override($method => $self->_build_override_method());
        return $self;
    }

    sub never {
        my ($self) = @_;
        $self->exactly(0);
        return $self;
    }

    sub exactly {
        my ($self, $times) = @_;
        unless ( defined $times ) {
            die "`exactly` requires a numerical argument.";
        }
        $self->{exactly} = $times;
        $self->{at_least} = undef;
        return $self;
    }

    sub at_least {
        my ($self, $times) = @_;
        unless ( defined $times ) {
            die "`exactly` requires a numerical argument.";
        }
        $self->{exactly} = undef;
        $self->{at_least} = $times;
        return $self;
    }

    sub _build_override_method {
        my ($self) = @_;
        return sub {
            my $object = shift;
            $self->{called_with} = \@_;
            $self->{called}++;

            if ($self->{call_through}) {
                my $method = $self->{mocked}{mock}->orig($self->{method});
                $object->$method(@_);
            } else {
                my $cb_or_value = $self->{returns};
                (ref($cb_or_value) eq 'CODE') ? $cb_or_value->($object, @_) : $cb_or_value;
            }
        }
    }

    sub returns {
        my ($self, $cb_or_value) = @_;
        $self->{call_through} = 0;
        $self->{returns} = $cb_or_value;
        return $self;
    }

    sub with {
        my ($self, @args) = @_;
        $self->{with} = \@args;
        return $self;
    }

    sub verify {
        my ($self) = @_;

        if (defined $self->{with}) {
            is $self->{called_with}, $self->{with}, "method " . $self->{method} . " is called with expected arguments";
        }

        if (defined $self->{exactly}) {
            is $self->{called}, $self->{exactly}, $self->{method} . " should be called exactly " . $self->{exactly} . " times";
        }
        elsif (defined $self->{at_least}) {
            ok $self->{called} > $self->{at_least}, $self->{method} . " is called at least " .  $self->{at_least} . " time";
        }
        else {
            ok $self->{called} > 0, $self->{method} . " is called at least 1 time";
        }

        return $self;
    }
}

1;
