package Bancuri::Controller::Auth;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

Bancuri::Controller::Auth - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub login : Local {
    my ( $self, $c ) = @_;

    my $authenticated = 0;

    # Get the id and optional password from form
    my $id = $c->request->params->{id} || "";
    my $password = $c->request->params->{password} || "";

    my $type = $c->forward('type', [ $id ]);
    if ( $type eq 'email' ) {
        $authenticated = $c->authenticate( { 
            email => $id, 
            password => $password,
    #        deleted => 0,
        }, $type);
    };

    if ( $authenticated ) {
        $c->forward('/redirect', [ '/' ]) unless $c->stash->{'AJAX'};
    }
    else {
       # or undef is authentication failed.  
       # so display the 'try again' page here.
       $c->response->body('Login failed');
    }
}

sub type : Local {
    my ( $self, $c, $id ) = @_;
    
    if ( $id =~ /@/ ) {
        return 'email';
    }
    else {
        return 'openid';
    }
}

sub logout : Local {
    my ( $self, $c ) = @_;
   
    $c->log->warn("GET /auth/logout") if $c->request->method eq 'GET';

    $c->logout();

    # Send the user to the starting point
    $c->response->redirect($c->uri_for('/'));
}

=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
