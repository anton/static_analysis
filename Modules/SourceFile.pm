package SourceFile;

use Cwd;

sub new {
    my $class = shift;
    my %params = @_;
    my $self = {};
    $self->{'filepath'} = $params{'filepath'};
    bless $self, $class;
    $self->generateRRDFilename();
    return $self;
}

sub createRRD {
    my $self = shift;
    my $rrd = $self->{'rrdfile'};

    die "ERROR: rrd not specified" unless($rrd);

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
    die "ERROR: unable to create '$rrd': $ERROR\n" if $ERROR;
}

sub generateRRDFilename {
    my $self = shift;
    $self->{'rrdfile'} = $self->{'filepath'};
    $self->{'rrdfile'} =~ s/\./_/g;
    $self->{'rrdfile'} =~ s/\//_/g;
    $self->{'rrdfile'} .= '.rrd';
    $self->{'rrdfile'} = getcwd . "/data/" . $self->{'rrdfile'};
}

sub update {
    my ($self, $loc, $cc) = @_;
    RRDs::update($self->{'rrdfile'}, "--template", "loc:cc", "N:$loc:$cc");
    my $ERROR = RRDs::error;
    die "ERROR: $ERROR\n" if($ERROR);
}

1;
