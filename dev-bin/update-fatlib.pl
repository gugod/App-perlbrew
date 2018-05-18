#!/usr/bin/env perl
use strict;
use App::FatPacker ();
use File::Path 2.08 qw(remove_tree);
use File::Basename;
use Cwd;

chdir dirname($0);

my $modules = [ split /\s+/, <<MODULES ];
local/lib.pm
Capture/Tiny.pm
CPAN/Perl/Releases.pm
JSON/PP.pm
MODULES

my $packer = App::FatPacker->new;
my @packlists = $packer->packlists_containing($modules);
$packer->packlists_to_tree(cwd . "/fatlib", \@packlists);

use Config;
remove_tree("fatlib/$Config{archname}");

use File::Find;
File::Find::find({
    wanted => sub {
        /^.*\.pod\z/s && unlink;
    } }, 'fatlib');

