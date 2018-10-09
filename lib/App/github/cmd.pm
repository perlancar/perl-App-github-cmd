package App::github::cmd;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;
use Log::ger;

our %SPEC;

$SPEC{':package'} = {
    summary => 'Yet another github CLI',
    v => 1.1,
};

our %args_common = (
    login => {
        schema => 'str*',
    },
    pass => {
        schema => 'str*',
    },
    access_token => {
        schema => 'str*',
    },
);
our %argsrels_common = (
    req_all => [qw/login pass/],
    req_one => [qw/login access_token/],
);
our %arg0_user = (
    user => {
        schema => 'str*',
        req => 1,
        pos => 0,
    },
);
our %argopt0_user = (
    user => {
        schema => 'str*',
        pos => 0,
    },
);
our %argopt_user = (
    user => {
        schema => 'str*',
    },
);
our %arg0_repo = (
    repo => {
        schema => 'str*',
        req => 1,
        pos => 0,
    },
);
our %argopt_detail = (
    detail => {
        schema => 'bool*',
        cmdline_aliases => {l=>{}},
    },
);

sub _init {
    my $args = shift;
    state $state = {};

    unless ($state->{_github}) {
        require Net::GitHub;
        my %ngargs;
        if ($args->{access_token}) {
            $ngargs{access_token} = $args->{access_token};
        } else {
            $ngargs{login} = $args->{login};
            $ngargs{pass}  = $args->{pass};
        }
        $state->{github} = Net::GitHub->new(%ngargs);
    }
    $state;
}

$SPEC{get_user} = {
    v => 1.1,
    summary => 'Get information about a user',
    args => {
        %args_common,
        %argopt0_user,
    },
};
sub get_user {
    my %args = @_;
    my $state = _init(\%args);
    my $github = $state->{github};

    my $user = $github->user->show($args{user});
    [200, "OK", $user];
}

$SPEC{get_repo} = {
    v => 1.1,
    summary => 'Get information about a repository',
    args => {
        %args_common,
        %argopt_user,
        %arg0_repo,
    },
};
sub get_repo {
    my %args = @_;
    my $state = _init(\%args);
    my $github = $state->{github};

    my $repo = $github->repos->get($args{user} // $args{login}, $args{repo});
    [200, "OK", $repo];
}

$SPEC{repo_exists} = {
    v => 1.1,
    summary => 'Check whether a repository exists',
    args => {
        %args_common,
        %argopt_user,
        %arg0_repo,
    },
};
sub repo_exists {
    my %args = @_;
    my $state = _init(\%args);
    my $github = $state->{github};

    my $repo;
    eval {
        $repo = $github->repos->get($args{user} // $args{login}, $args{repo});
    };
    my $err = $@;
    my $exists = $err && $err =~ /Not Found/ ? 0 : 1;
    [200, "OK", $exists];
}

$SPEC{list_repos} = {
    v => 1.1,
    summary => "List user's repositories",
    args => {
        %args_common,
        %argopt_detail,
        start => {
            schema => 'nonnegint*',
            default => 0,
        },
    },
};
sub list_repos {
    my %args = @_;
    my $state = _init(\%args);
    my $github = $state->{github};

    my @repos = $github->repos->list($args{start});
    unless ($args{detail}) {
        @repos = map { $_->{name} } @repos;
    }
    [200, "OK", \@repos];
}

$SPEC{create_repo} = {
    v => 1.1,
    summary => 'Create a repository',
    args => {
        %args_common,
        %arg0_repo,
        description => {
            schema => 'str*',
        },
        homepage => {
            schema => 'url*',
        },
    },
};
sub create_repo {
    my %args = @_;
    my $state = _init(\%args);
    my $github = $state->{github};

    my $repo = $github->repos->create({
        name => $args{repo},
        description => $args{description} // '(No description)',
        homepage    => $args{homepage} ? "$args{homepage}" : 'https://github.com',
    });
    [200, "OK", $repo];
}

$SPEC{delete_repo} = {
    v => 1.1,
};
sub delete_repo {
    [501, "Not yet implemented"];
}


1;
# ABSTRACT:

=head1 SYNOPSIS

Please see included script L<github-cmd>.


=head1 SEE ALSO
