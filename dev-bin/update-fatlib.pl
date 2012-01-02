#!/usr/bin/env perl
use strict;
use App::FatPacker ();
use File::Path;
use Cwd;

my $modules = [ split /\s+/, <<MODULES ];
local/lib.pm
File/Path/Tiny.pm
Capture/Tiny.pm
CPAN/Perl/Releases.pm
MODULES

my $packer = App::FatPacker->new;
my @packlists = $packer->packlists_containing($modules);
$packer->packlists_to_tree(cwd . "/fatlib", \@packlists);

use Config;
rmtree("fatlib/$Config{archname}");

use File::Find;
File::Find::find({
    wanted => sub {
        /^.*\.pod\z/s && unlink;
    } }, 'fatlib');

if (my $strip = `which perlstrip`) {
    chomp($strip);
    my @files;
    File::Find::find({
        wanted => sub {
            /^.*\.pm\z/s or return;
            push @files, $File::Find::name;

        } }, 'fatlib');

    for (@files){
        system($strip, $_);
    }
}
