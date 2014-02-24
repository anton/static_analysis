#!/usr/bin/perl
use strict;
use warnings;
use lib qw(Modules);
use Git;
use Cwd;
$|++;

my $git = Git->new(repo_path => ".");
$git->set_start("f9bbc11");
$git->set_end("36a09d9");
my @commits = $git->get_intermediate_commits();
foreach (@commits) {
    print $_;
    $git->checkout($_);
    print join("\n", $git->list_changed_files()), "\n\n";
}
