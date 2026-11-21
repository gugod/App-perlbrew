# Always requires the latest for this two.
requires 'CPAN::Perl::Releases' => '5.20261119';
requires 'Devel::PatchPerl'     => '2.14';

requires 'Capture::Tiny'        => '0.50';
requires 'Pod::Usage'           => '1.69';
requires 'File::Copy'           => '0';
requires 'File::Temp'           => '0.2304';
requires 'JSON::PP'             => '0';
requires 'local::lib'           => '2.000014';

on test => sub {
    requires 'File::Temp'           => '0.2304';
    requires 'File::Which'          => '1.21';
    requires 'Path::Class'          => '0.33';
    requires 'Test2::V0'            => '0.000163';
    requires 'Test2::Plugin::NoWarnings' => '0.10';
    requires 'Test2::Plugin::IOEvents' => '0.001001';
};

on develop => sub {
    requires 'Pod::Markdown' => '2.002';
};
