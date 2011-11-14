#!/usr/bin/env perl
use strict;
use App::FatPacker ();
use File::Path;
use Cwd;

my $modules = [ split /\s+/, <<MODULES ];
local/lib.pm
File/Path/Tiny.pm
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
