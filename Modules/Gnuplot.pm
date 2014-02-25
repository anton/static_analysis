package Gnuplot;

sub new {
    my $class = shift;
    my %params = @_;
    my $self = {};

    $self->{'image'} = $params{'image'}; # cc or loc
    $self->{'type'} = $params{'type'}; # cc or loc
    $self->{'gp'} = `mktemp --suffix=gnuplot`;
    $self->{'gp'} =~ s/\n//;

    bless $self, $class;
}

sub add {
    my $self = shift;
    my $dat = shift;

    my $type = $dat->{'type'};

    unless ($type =~ /$self->{'type'}/) {
        return;
    }

    foreach(@{$self{"datfiles_$type"}}) {
        if ($_->{'datfile'} =~ /$dat->{'datfile'}/) {
            return;
        }
    }

    push(@{$self{"datfiles_$type"}}, $dat);
}

sub draw {
    my $self = shift;

    open(FILE, ">", $self->{'gp'});
    print(FILE "set terminal png size 1024,768\n");
    print(FILE "set output \"$self->{'image'}\"\n");
    print(FILE "set key out vert bot center\n");
    print(FILE "set xlabel \"Date\"\n");
    if($self->{'type'} =~ /cc/) {
        print(FILE "set ylabel \"Cyclomatic complexity\"\n");
    } elsif($self->{'type'} =~ /loc/) {
        print(FILE "set ylabel \"Lines of code\"\n");
    }
    print(FILE "set xdata time\n"); # The x axis data is time
    print(FILE "set timefmt \"%s\"\n");  # The dates in the file look like 10-Jun-04
    print(FILE "set format x \"%b-%y\"\n"); # On the x-axis, we want tics like Jun 08
    print(FILE "plot \\\n");

    my $cnt = 0;
    my $type = $self->{'type'};
    foreach(@{$self{"datfiles_$type"}}) {
        my $dat = $_;

        print(FILE "'$dat->{'datfile'}' using 1:2 ");
        print(FILE "title '$dat->{'filepath'}' with lines");

        $cnt++;

        if($cnt < scalar @{$self{"datfiles_$type"}}) {
            print(FILE ", \\\n");
        } else {
            print(FILE "\n");
        }

    }

    close(FILE);

    system("gnuplot $self->{'gp'}");
    system("rm $self->{'gp'}");
}

1;
