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
    },
    pass => {
    },
    access_token => {
    },
);
our %argsrels_common = (
    req_all => [qw/login pass/],
    req_one => [qw/login access_token/],
);

$SPEC{repo_exists} = {
    v => 1.1,
};
sub repo_exists {
}

$SPEC{create_repo} = {
    v => 1.1,
};
sub create_repo {
}

$SPEC{delete_repo} = {
    v => 1.1,
};
sub delete_repo {
}


1;
# ABSTRACT:

=head1 SYNOPSIS

Please see included script L<github-cmd>.


=head1 SEE ALSO
