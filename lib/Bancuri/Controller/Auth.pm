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
    if ( $type eq 'email' and length $password ) {
        $authenticated = $c->authenticate( { 
            email => $id,
            password => $password,
#           deleted => 0,
        }, $type);
    };
    
#    if ( $type eq 'openid' ) {
#        $authenticated = $c->authenticate( { 
#            url => $id, 
#            deleted => 0,
#        }, $type);
#    }

    if ( $authenticated ) {
        if ( $c->stash->{'AJAX'} ) {
            $c->stash->{'json_login'} = {
                id => $id,
                name => $c->user->name,
            };
        }
        else {
            $c->forward('/redirect', [ '/' ]);
        }
    }
    else {
       # or undef is authentication failed.  
       # so display the 'try again' page here.
       $c->response->body('Login failed');
    }
}

sub type : Local {
    my ( $self, $c, $id ) = @_;
    
    $c->log->debug("ID ".$id);
    if ( $id =~ /@/ ) {
        $c->log->debug("EMAIL");
        return 'email';
    }
    else {
        return 'openid';
    }
}

sub id_exists : Local {
    my ( $self, $c ) = @_;

    my $id = $c->request->params->{'id'};
    my $user = $c->model('BancuriDB::Users')->find({email=>$id});
    # TODO also search openid
    
    $c->stash->{'json_id_exists'} = $user ? $id : 0;
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
