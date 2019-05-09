requires 'CPAN::Perl::Releases' => '3.88';
requires 'Capture::Tiny'        => '0.36';
requires 'Devel::PatchPerl'     => '1.54';
requires 'Pod::Parser'          => '1.63';
requires 'Pod::Usage'           => '1.68';
requires 'File::Temp'           => '0.2304';
requires 'JSON::PP'             => '0';
requires 'local::lib'           => '2.000014';
requires 'ExtUtils::MakeMaker'  => '7.22';
    
on test => sub {
    requires 'File::Temp'           => '0.2304';
    requires 'File::Which'          => '1.21';
    requires 'IO::All'              => '0.51';
    requires 'Path::Class'          => '0.33';
    requires 'Test::Exception'      => '0.32';
    requires 'Test::More'           => '1.001002';
    requires 'Test::NoWarnings'     => '1.04';
    requires 'Test::Output'         => '1.03';
    requires 'Test::Simple'         => '1.001002';
    requires 'Test::Spec'           => '0.47';
    requires 'Test::TempDir::Tiny'  => '0.016';
};

on develop => sub {
    requires 'Pod::Markdown' => '2.002';
};
