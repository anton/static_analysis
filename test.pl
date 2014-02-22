#!/usr/bin/perl
use strict;
use warnings;
use RRDs;
use lib qw(Modules);
use SourceFile;
$|++;

sub createProperRRDFilename {
    my $sourcefile = SourceFile->new(filepath => "foo.c");
    $sourcefile->generateRRDFilename();
    $sourcefile->{'rrdfile'} =~ /^data\/foo_c.rrd$/ || die "createProperRRDFilename fail";

    $sourcefile = SourceFile->new(filepath => "/foo/bar/baz.c");
    $sourcefile->generateRRDFilename();
    $sourcefile->{'rrdfile'} =~ /^data\/_foo_bar_baz_c.rrd$/ || die "createProperRRDFilename fail";
}

sub createRRDFile {
    `rm -f data/foo_c.rrd`;
    my $sourcefile = SourceFile->new(filepath => "foo.c");
    $sourcefile->createRRD();
    die "rrd not created" unless(-f "data/foo_c.rrd");

    my $s = SourceFile->new(filepath => "foo.c");
    $s->createRRD();
}

sub testUpdate {
    my $sourcefile = SourceFile->new(filepath => "foo.c");
    $sourcefile->update(1, 2);
}

# TODO move this function to a new test script
sub fillRRD {
    my $sourcefile = SourceFile->new(filepath => "foo.c");
    my $time = time;
    my $loc = 5;
    my $cc = 10;
    foreach(1..100) {
        $time = time + $_ * 3600;
        $loc++ if($_ % 3 == 0);
        $cc++  if($_ % 4 == 0);
        $loc-- if($_ % 8 == 0);
        $cc--  if($_ % 9 == 0);
        RRDs::update($sourcefile->{'rrdfile'}, "--template", "loc:cc", "$time:$loc:$cc");
        my $ERROR = RRDs::error;
        die "$ERROR\n" if($ERROR);
    }
}

# TODO move this function to a new test script
sub drawImage {
    my $sourcefile = SourceFile->new(filepath => "foo.c");
    $sourcefile->graph();
}

createProperRRDFilename();
createRRDFile();
testUpdate();
fillRRD();
drawImage();
