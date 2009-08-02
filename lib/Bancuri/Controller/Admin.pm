package Bancuri::Controller::Admin;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

Bancuri::Controller::Admin - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 auto

Check if there is a user and, if not, forward to login page

=cut

# Note that 'auto' runs after 'begin' but before your actions and that
# 'auto' "chain" (all from application path to most specific class are run)
sub auto : Private {
    my ($self, $c) = @_;

    # If a user doesn't exist, force login
    unless ($c->user_exists) {
        # Dump a log message to the development server debug output
        $c->log->debug('User not found, forwarding to login');
        # Redirect the user to the login page
        $c->response->redirect($c->uri_for('/auth/form'));
        # Return 0 to cancel 'post-auto' processing and prevent use of application
        return 0;
    }
    
    # Check that the user is admin
    unless ($c->check_user_roles('admin')) {
        $c->response->body('Unauthorized!');
        return 0;
    }

    # User found, so return 1 to continue with processing after this 'auto'
    return 1;
}

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{'template'} = 'admin.html';
}


=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;