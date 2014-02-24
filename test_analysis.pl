#!/usr/bin/perl
use strict;
use warnings;
use lib qw(Modules);
use Analysis;
$|++;

sub testLOC {
    my $loc = `cat ./test_analysis.pl | wc -l`;
    $loc =~ s/\n//;
    my $analysis = Analysis->new();
    $analysis->loc("./test_analysis.pl") == $loc || die "loc is wrong";
    $analysis->loc("./test.pl") != $loc || die "loc is wrong";
}

sub testCC {
    my $cc = `grep if ./test.pl | wc -l`;
    $cc =~ s/\n//;

    my $analysis = Analysis->new();
    $analysis->cc("./test.pl") == $cc + 1 || die "cc is wrong";
}

testLOC();
testCC();
