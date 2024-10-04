use Test2::V0;
use App::Perlbrew::Util qw(looks_like_url_of_skaji_relocatable_perl looks_like_sys_would_be_compatible_with_skaji_relocatable_perl);

subtest "looks_like_url_of_skaji_relocatable_perl", sub {
    is(
        looks_like_url_of_skaji_relocatable_perl($_),
        hash {
            field url => string($_);
            field version => string('5.40.0.0');
            field os => in_set(
                string('darwin'),
                string('linux'),
            );
            field arch => string("amd64");
            field original_filename => match(qr/^perl-(.+?)-amd64\.tar\.gz$/);
            end();
        },
        "positive case: $_"
    ) for qw(
                https://github.com/skaji/relocatable-perl/releases/download/5.40.0.0/perl-darwin-amd64.tar.gz
                https://github.com/skaji/relocatable-perl/releases/download/5.40.0.0/perl-linux-amd64.tar.gz
        );

    is(looks_like_url_of_skaji_relocatable_perl($_), F(), "negative case: $_")
        for qw(
                  https://example.com/
                  https://gugod.org/
                  https://github.com/skaji/relocatable-perl/releases/download/5.40.0.0/perl-linux-x86_64.tar.gz
          );
};

subtest "looks_like_sys_would_be_compatible_with_skaji_relocatable_perl", sub {
    my $detail = looks_like_url_of_skaji_relocatable_perl("https://github.com/skaji/relocatable-perl/releases/download/5.40.0.0/perl-linux-amd64.tar.gz");

    my @positiveCases = (
        (mock {} =>
            add => [
                os => sub { "linux" },
                arch => sub { "amd64" },
            ]),
        (mock {} =>
            add => [
                os => sub { "linux" },
                arch => sub { "x86_64" },
            ]),
    );

    my @negativeCasse = (
        (mock {} =>
            add => [
                os => sub { "linux" },
                arch => sub { "arm64" },
            ]),
        (mock {} =>
            add => [
                os => sub { "darwin" },
                arch => sub { "aarch64" },
            ]),
        (mock {} =>
            add => [
                os => sub { "darwin" },
                arch => sub { "x86_64" },
            ]),
    );


    is looks_like_sys_would_be_compatible_with_skaji_relocatable_perl($detail, $_), T()
        for @positiveCases;

    is looks_like_sys_would_be_compatible_with_skaji_relocatable_perl($detail, $_), F()
        for @negativeCasse;
};

done_testing;
