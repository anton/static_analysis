package Git;

use Cwd;

sub new {
    my $class = shift;
    my %params = @_;
    my $self = {};
    $self->{'repo_path'} = $params{'repo_path'};
    bless $self, $class;
}

sub checkout {
    my $self = shift;
    my $commit = shift;
    my $dir = getcwd;
    chdir $self->{'repo_path'};
    system("git checkout -q $commit");
    chdir $dir;
}

sub list_changed_files {
    my $self = shift;
    my $dir = getcwd;
    my @ret = ();
    chdir $self->{'repo_path'};
    foreach(`git show --numstat`) {
        if (/^[0-9]+[ \t]+[0-9]+[ \t]+(.*?)$/) {
            push @ret, $self->{'repo_path'}."/".$1;
        }
    }
    chdir $dir;
    return @ret;
}

sub set_start {
    my $self = shift;
    my $commit = shift;
    $self->{'start'} = $commit;
}

sub set_end {
    my $self = shift;
    my $commit = shift;
    $self->{'end'} = $commit;
}

sub get_intermediate_commits {
    my $self = shift;
    my $dir = getcwd;
    chdir $self->{'repo_path'};
    my @ret = `git log --format="%h" $self->{'start'}..$self->{'end'}`;
    chdir $dir;
    return @ret;
}

sub get_commit_time {
    my $self = shift;
    my $dir = getcwd;
    chdir $self->{'repo_path'};
    my $timestamp = `git show -s --format=%ct`;
    $timestamp =~ s/\n//;
    chdir $dir;
    return $timestamp;
}

1;
