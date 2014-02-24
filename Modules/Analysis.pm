package Analysis;

sub new {
    my $class = shift;
    my %params = @_;
    my $self = {};
    bless $self, $class;
}

# Lines of code
sub loc {
    my $class = shift;
    my $filename = shift;

    my $lines = 0;
    open(FILE, $filename) or die "Can't open `$filename': $!";
    while (sysread FILE, $buffer, 4096) {
        $lines += ($buffer =~ tr/\n//);
    }
    close(FILE);

    return $lines;
}

# Rough estimation of cyclomatic complexity. Counting number of "if" statements
# in file.
sub cc {
    my $class = shift;
    my $filename = shift;

    my $if = 0;
    open(FILE, $filename) or die "Can't open `$filename': $!";
    foreach(<FILE>) {
        $if++ if (/if/);
    }
    close(FILE);

    return $if + 1;
}

1;
