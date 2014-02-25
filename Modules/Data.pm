package Data;

use Cwd;

sub new {
    my $class = shift;
    my %params = @_;
    my $self = {};
    $self->{'filepath'} = $params{'filepath'};
    $self->{'type'} = $params{'type'};
    bless $self, $class;
    $self->generateDatFilename();
    return $self;
}

sub generateDatFilename {
    my $self = shift;
    $self->{'datfile'} = $self->{'filepath'};
    $self->{'datfile'} =~ s/\./_/g;
    $self->{'datfile'} =~ s/\//_/g;
    $self->{'datfile'} .= '_' . $self->{'type'};
    $self->{'datfile'} .= '.dat';
    $self->{'datfile'} = getcwd . "/data/" . $self->{'datfile'};
}

sub append {
    my ($self, $val) = @_;
    open(FILE, ">>", $self->{'datfile'});
    printf(FILE "%d %d\n", time, $val);
    close(FILE);
}

1;
