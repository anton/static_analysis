#!/usr/bin/perl
use strict;
use warnings;
use RRDs;
use lib qw(Modules);
use Gnuplot;
use Data;
$|++;

system("rm data/*.dat");
system("rm img/cc.png");

my $gnuplot = Gnuplot->new(image => 'img/cc.png', type => 'cc');

my $data = Data->new(filepath => "foo.c", type => 'cc');
$data->append(10);
$data->append(11);
$data->append(12);

open(FILE, ">>", $data->{'datfile'});
printf(FILE "%d %d\n", time + 1000, 13);
close(FILE);

my $bar = Data->new(filepath => "bar.c", type => 'cc');
$bar->append(20);
$bar->append(31);
$bar->append(42);

open(FILE, ">>", $bar->{'datfile'});
printf(FILE "%d %d\n", time + 1000, 12);
close(FILE);

$gnuplot->add($data);
$gnuplot->add($bar);

$gnuplot->draw();
