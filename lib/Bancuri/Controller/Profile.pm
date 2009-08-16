package Bancuri::Controller::Profile;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

Bancuri::Controller::Profile - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

# Note that 'auto' runs after 'begin' but before your actions and that
# 'auto's "chain" (all from application path to most specific class are run)
# See the 'Actions' section of 'Catalyst::Manual::Intro' for more info.
sub auto : Private {
    my ($self, $c) = @_;

    # If a user doesn't exist, force login
    if (!$c->user_exists) {
        # Redirect the user to the login page
        $c->response->redirect('/auth/form', { next_page => $c->req->uri });
        # Return 0 to cancel 'post-auto' processing and prevent use of application
        return 0;
    }

    # User found, so return 1 to continue with processing after this 'auto'
    return 1;
}


sub index : Path Args(0) {
    my ($self, $c) = @_;
    
    $c->stash( template => 'profile.html' );
}

sub favorites : Global {
    my ($self, $c) = @_;
    
    my $page = $c->req->params->{'page'} || 1;
    my $per_page = 10;
    
    my $favorites = $c->model('DB::JokeVersion')
        ->favorites_for( user_id => $c->user->id )
        ->search(undef, {
            rows    => $per_page,
        })->page($page);

    $c->stash( 
        favorites   => $favorites,
        pager       => $favorites->pager,
        template    => 'profile/favorites.html', 
    );
}


=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
