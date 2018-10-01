package Perinci::CmdLine::github::cmd;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;
use Log::ger;

use parent 'Perinci::CmdLine::Lite';

sub hook_before_parse_argv {
    my ($self, $r) = @_;

    # we want to run 'setup' when user runs 'github-cmd' the first time (without
    # any subcommand) and without login/pass or token specified in the config
    # file
  RUN_SETUP:
    {
        $self->_parse_argv1($r);
        last if $r->{subcommand_name};
        $self->_read_config($r) unless $r->{config};
        last if defined($r->{config}{GLOBAL}{login}) &&
            defined($r->{config}{GLOBAL}{pass}) ||
            defined($r->{config}{GLOBAL}{token});
        log_trace "User does not have defined login+pass or token in ".
            "configuration, running setup ...";
        # XXX RUN SETUP
    }
}

1;
# ABSTRACT: Subclass for github-cmd
