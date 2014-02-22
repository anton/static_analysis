package SourceFile;

sub new {
    my $class = shift;
    my %params = @_;
    my $self = {};
    $self->{'filepath'} = $params{'filepath'};
    bless $self, $class;
    $self->generateRRDFilename();
    $self->generateIMGFilename();
    return $self;
}

sub createRRD {
    my $self = shift;
    my $rrd = $self->{'rrdfile'};
    die "rrd not specified" unless($rrd);

    return if (-f $rrd);

    RRDs::create ($rrd, "--step", 3600,
            "DS:loc:GAUGE:36000:U:U",
            "DS:cc:GAUGE:36000:U:U",
            # Step size == 3600s (1h)
            # Month, 1 hour
            "RRA:AVERAGE:0.5:1:720",
            # Year, 10 hours
            "RRA:AVERAGE:0.5:10:876",
            # 10 years, 100 hours
            "RRA:AVERAGE:0.5:100:876",
    );
    my $ERROR = RRDs::error;
    die "$0: unable to create '$rrd': $ERROR\n" if $ERROR;
}

sub generateRRDFilename {
    my $self = shift;
    $self->{'rrdfile'} = $self->{'filepath'};
    $self->{'rrdfile'} =~ s/\./_/g;
    $self->{'rrdfile'} =~ s/\//_/g;
    $self->{'rrdfile'} .= '.rrd';
    $self->{'rrdfile'} = "data/" . $self->{'rrdfile'};
}

# TODO remove this function
sub generateIMGFilename {
    my $self = shift;
    $self->{'graph'} = $self->{'filepath'};
    $self->{'graph'} =~ s/\./_/g;
    $self->{'graph'} =~ s/\//_/g;
    $self->{'graph'} .= '.png';
    $self->{'graph'} = "img/" . $self->{'graph'};
}

sub update {
    my ($self, $loc, $cc) = @_;
    RRDs::update($self->{'rrdfile'}, "--template", "loc:cc", "N:$loc:$cc");
    my $ERROR = RRDs::error;
    die "$ERROR\n" if($ERROR);
}

# TODO move this function elsewhere
sub graph {
    use Digest::MD5;
    my @colorlist = (
            "#FFFF00",
            "#00a0a0",
            "#a000a0",
            "#0000a0",
            );

    my $self = shift;
    my @start = ('-s','now');
    my @end = ('-e','+72hour');
    my @arg;
    my $col;
    my $name;

    $col = pop @colorlist;
    $name = "loc".Digest::MD5::md5_hex($self->{'rrdfile'});
    push @arg,
         "DEF:$name=$self->{'rrdfile'}:loc:AVERAGE",
         "LINE2:$name$col:$self->{'filepath'} loc",
         ;

    $col = pop @colorlist;
    $name = "cc".Digest::MD5::md5_hex($self->{'rrdfile'});
    push @arg,
         "DEF:$name=$self->{'rrdfile'}:cc:AVERAGE",
         "LINE2:$name$col:$self->{'filepath'}  cc",
         ;

    RRDs::graph("$self->{'graph'}",
        "--title","Title",
#        "--lazy",
        @end,
        @start,
        "-w", "800",
        "-h", "600",
        @arg);
    die "$ERROR\n" if ($ERROR = RRDs::error);
}

1;
