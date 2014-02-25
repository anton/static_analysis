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

    if ($dat->{'type'} !~ /$self->{'type'}/) {
        return;
    }

    foreach(@{$self{'datfiles'}}) {
        if ($_->{'datfile'} =~ /$dat->{'datfile'}/) {
            return;
        }
    }

    push(@{$self{'datfiles'}}, $dat);
}

sub draw {
    my $self = shift;

    open(FILE, ">", $self->{'gp'});
    print(FILE "set terminal png\n");
    print(FILE "set output \"$self->{'image'}\"\n");
    print(FILE "plot \\\n");

    my $cnt = 0;
    foreach(@{$self{'datfiles'}}) {
        my $dat = $_;

        print(FILE "'$dat->{'datfile'}' using 1:2 ");
        print(FILE "title '$dat->{'filepath'}' with lines");

        $cnt++;

        if($cnt < scalar @{$self{'datfiles'}}) {
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
