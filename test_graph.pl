#!/usr/bin/perl
use strict;
use warnings;
use RRDs;
use Digest::MD5;
use lib qw(Modules);
use Graph;
use SourceFile;
$|++;

system("rm img/cc.png data/foo_c.rrd");

my $graph = Graph->new(image => 'img/cc.png', type => 'cc');

my $sourcefile = SourceFile->new(filepath => "foo.c");
$sourcefile->createRRD();
$graph->add_rrd($sourcefile);

my $time = time;
my $loc = 5;
my $cc = 10;
foreach(1..10) {
    $time = time + $_ * 3600;
    $loc++ if($_ % 3 == 0);
    $cc++  if($_ % 4 == 0);
    $loc-- if($_ % 8 == 0);
    $cc--  if($_ % 9 == 0);
    RRDs::update($sourcefile->{'rrdfile'}, "--template", "loc:cc", "$time:$loc:$cc");
    my $ERROR = RRDs::error;
    die "$ERROR\n" if($ERROR);
}

$graph->{'start'} = "now";
$graph->{'end'} = "+72hour";
$graph->draw();
