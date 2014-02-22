#!/usr/bin/perl
use strict;
use warnings;
use RRDs;
use lib qw( Modules/ );
use SourceFile;
$|++;

sub createProperRRDFilename {
    my $sourcefile = SourceFile->new(filepath => "foo.c");
    $sourcefile->generateRRDFilename();
    $sourcefile->{'rrdfile'} =~ /foo_c.rrd/ || die "createProperRRDFilename fail";

    $sourcefile = SourceFile->new(filepath => "/foo/bar/baz.c");
    $sourcefile->generateRRDFilename();
    $sourcefile->{'rrdfile'} =~ /foo_bar_baz_c.rrd/ || die "createProperRRDFilename fail";
}

sub createRRDFile {
    `rm -f data/foo_c.rrd`;
    my $sourcefile = SourceFile->new(filepath => "foo.c");
    $sourcefile->createRRD();
    die "rrd not created" unless(-f "data/foo_c.rrd");

    my $s = SourceFile->new(filepath => "foo.c");
    $s->createRRD();
}

createProperRRDFilename();
createRRDFile();
