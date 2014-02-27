package Graph;

sub new {
    my $class = shift;
    my %params = @_;
    my $self = {};
    $self->{'graph'} = $params{'image'};
    $self->{'type'} = $params{'type'}; # cc or loc
    $self->{'start'} = "-1week";
    $self->{'end'} = "now";
    bless $self, $class;
    return $self;
}

sub add_rrd {
    my $self = shift;
    my $rrd = shift;
    my $type = $self->{'type'};
    foreach(@{$self{"rrds_$type"}}) {
        if ($_->{'rrdfile'} =~ /$rrd->{'rrdfile'}/) {
            return;
        }
    }

    push(@{$self{"rrds_$type"}}, $rrd);
}

sub random_color {
    my $self = shift;
    return sprintf("#%x%x%x%x%x%x",
    int(rand(16)), int(rand(16)),
    int(rand(16)), int(rand(16)),
    int(rand(16)), int(rand(16)));
}

sub draw {
    my $self = shift;

    my @start = ('-s', $self->{'start'});
    my @end   = ('-e', $self->{'end'});
    my @arg;
    my $name;
    my $type = $self->{'type'};

    my $title = "";
    if ($type =~ /loc/) {
        $title = "Lines of code";
    } elsif ($type =~ /cc/) {
        $title = "Cyclomatic complexity";
    } else {
        die "ERROR: $type: wrong type";
    }

    foreach(@{$self{"rrds_$type"}}) {
        my $rrd = $_;

        my $col = $self->random_color();
        $name = Digest::MD5::md5_hex($rrd->{'rrdfile'});
        push @arg,
             "DEF:$name=$rrd->{'rrdfile'}:$type:AVERAGE",
             "LINE2:$name$col:$rrd->{'filepath'}",
             "GPRINT:$name:LAST:%5.0lf",
             "COMMENT: \\n",
             ;
    }

    RRDs::graph($self->{'graph'},
        "--title",$title,
#        "--lazy",
        @end,
        @start,
        "-w", "800",
        "-h", "600",
        @arg);
    die "ERROR: $ERROR\n" if ($ERROR = RRDs::error);
}

sub year {
    my $self = shift;
    $self->{'start'} = "-1year";
}

sub six_months {
    my $self = shift;
    $self->{'start'} = "-6month";
}

sub month {
    my $self = shift;
    $self->{'start'} = "-1month";
}

sub week {
    my $self = shift;
    $self->{'start'} = "-1week";
}

sub day {
    my $self = shift;
    $self->{'start'} = "-1day";
}

1;
