use Test2::V0;

use App::perlbrew;

subtest 'sys', sub {
    my $o = App::perlbrew->new();
    is $o->can("sys"), T();
    is $o->sys->os(), D();
    is $o->sys->arch(), D();
    is $o->sys->osname(), D();
    is $o->sys->archname(), D();
};

done_testing;
