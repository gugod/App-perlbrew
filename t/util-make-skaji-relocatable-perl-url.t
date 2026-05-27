use Test2::V0;
use App::Perlbrew::Sys;
use App::Perlbrew::Util qw(make_skaji_relocatable_perl_url);

subtest 'make_skaji_relocatable_perl_url', sub {
    my $expected_os;
    my $expected_arch;

    if ($ENV{CI} && $ENV{GITHUB_ACTION} && $ENV{RUNNER_OS}) {
        if ($ENV{RUNNER_OS} eq "macOS" && $ENV{RUNNER_ARCH}) {
            # Possible value fo RUNNER_ARCH are: X86, X64, ARM, or ARM64.
            # Ref: https://docs.github.com/en/actions/reference/workflows-and-actions/variables
            $expected_os = "darwin";
            $expected_arch = {
                "X86" => "amd64",
                "X64" => "amd64",
                "ARM" => "arm64",
                "ARM64" => "arm64",
            }->{$ENV{RUNNER_ARCH}};
        }
    }

    my $url = make_skaji_relocatable_perl_url(
        "skaji-relocatable-perl-5.42.2.0",
        'App::Perlbrew::Sys'
    );

    like(
        $url,
        qr(/download/5.42.2.0/perl-
           (linux|darwin)
           -
           (amd64|arm64)
           \.tar\.gz
           \z )x,
        "With a generic pattern.");

    if ($expected_os && $expected_arch) {
        like(
            $url,
            qr(/download/5.42.2.0/perl-
               \Q${expected_os}\E
               -
               \Q${expected_arch}\E
               \.tar\.gz
               \z )x,
            "With exact os and arch");
    }

};

done_testing;
