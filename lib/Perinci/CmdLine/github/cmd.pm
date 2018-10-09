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
            defined($r->{config}{GLOBAL}{access_token});
        log_trace "User does not have defined login+pass or token in ".
            "configuration, running setup ...";
        require Term::ReadKey;
        my ($login, $pass);
        while (1) {
            print "Setting up github-cmd. Please enter GitHub login: ";
            chomp($login = <STDIN>);
            last if $login =~ /\A\w+\z/;
        }
        while (1) {
            print "Please enter GitHub password: ";
            Term::ReadKey::ReadMode('noecho');
            chomp($pass = <STDIN>);
            Term::ReadKey::ReadMode('normal');
            print "\n";
            last if length $login;
        }
        require PERLANCAR::File::HomeDir;
        my $path = PERLANCAR::File::HomeDir::get_my_home_dir() .
            "/github-cmd.conf";
        require Config::IOD;
        my $iod = Config::IOD->new;
        require Config::IOD::Document;
        my $doc = (-f $path) ? $iod->read_file($path) :
            Config::IOD::Document->new;
        $doc->insert_section({ignore=>1}, 'GLOBAL');
        $doc->insert_key({replace=>1}, 'GLOBAL', 'login', $login);
        $doc->insert_key({replace=>1}, 'GLOBAL', 'pass', $pass);
        open my $fh, ">", $path or die "Can't write config '$path': $!";
        print $fh $doc->as_string;
        close $fh;

        # early exit
        print "Setup done, please run 'github-cmd' again.\n";
        exit 0;
    } # RUN_SETUP
}

1;
# ABSTRACT: Subclass for github-cmd

=head1 DESCRIPTION

This subclass adds a hook at the C<before_parse_argv> phase to run setup
(prompting login+pass, then writing configuration file) if login+pass are not
found in configuration.
