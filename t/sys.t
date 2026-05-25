use Test2::V0;

use App::perlbrew;
use Capture::Tiny qw(capture_stdout);

subtest 'sys', sub {
    my $o = App::perlbrew->new();
    is $o->can("sys"), T();
    is $o->sys->os(), D();
    is $o->sys->arch(), D();
    is $o->sys->osname(), D();
    is $o->sys->archname(), D();

    if ($o->sys->os() eq 'darwin') {
        subtest 'macOS', sub {
            my $arch_by_uname = capture_stdout {
                system("uname", "-m") == 0
                    or die "system() failed: uname -m. Error: $!";
            };
            $arch_by_uname =~ s/\n$//;

            is $o->sys->archname(), $arch_by_uname, "archname: should match the output of `uname -m`.";
        };
    }
};

done_testing;
