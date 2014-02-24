package Graph;

sub new {
    my $class = shift;
    my %params = @_;
    my $self = {};
    $self->{'graph'} = $params{'image'};
    $self->{'type'} = $params{'type'}; # cc or loc
    bless $self, $class;
    $self->create_color_list();
    return $self;
}

sub add_rrd {
    my $self = shift;
    my $rrd = shift;
    push(@{$self{'rrds'}}, $rrd);
}

sub create_color_list {
    my $self = shift;
    push(@{$self{'color'}}, "#FFFF00");
    push(@{$self{'color'}}, "#00a0a0");
    push(@{$self{'color'}}, "#a000a0");
    push(@{$self{'color'}}, "#00a0a0");
}

sub draw {
    my $self = shift;

    my @start = ('-s','now');
    my @end = ('-e','+72hour');
    my @arg;
    my $col;
    my $name;
    my $type = $self->{'type'};

    my $title = "";
    if ($type =~ /loc/) {
        $title = "Lines of code";
    } elsif ($type =~ /cc/) {
        $title = "Cyclomatic complexity";
    } else {
        die "$type: wrong type";
    }

    foreach(@{$self{'rrds'}}) {
        my $rrd = $_;

        $col = pop(@{$self{'color'}});
        $name = Digest::MD5::md5_hex($rrd->{'rrdfile'});
        push @arg,
             "DEF:$name=$rrd->{'rrdfile'}:$type:AVERAGE",
             "LINE2:$name$col:$rrd->{'filepath'}",
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
    die "$ERROR\n" if ($ERROR = RRDs::error);
}

1;