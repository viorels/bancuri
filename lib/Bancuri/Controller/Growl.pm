package Bancuri::Controller::Growl;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use utf8;

=head1 NAME

Bancuri::Controller::Growl - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body(join q{ }, @{ $c->session->{'changes'} });
}

sub messages :Local {
    my ( $self, $c ) = @_;
    
    my $messages = [];
    
    # get changes for current session with no assigned user
    my @changes = $c->model('DB::Change')->search_for_session($c->sessionid)->all();
    @changes = grep { not $_->user_id } @changes; 
    if ( @changes > 0 and not $c->session->{'growl_suppress'}{'changes'} ) {
        push @$messages, {
            header  => "Salut,",
            message => "Ai făcut ".@changes." modificiari la bancuri !
                        Dacă vrei ca schimbarile să rămână atunci spune-mi te rog
                        <a href=". $c->uri_for('/auth/form') .">cine eşti</a>.",
            type    => 'changes',
        }
    }

    # get 5 stars votes for current session with no assigned user
    my @votes = $c->model('DB::Vote')->search_for_session($c->sessionid)->all();
    @votes = grep { not $_->user_id and $_->rating == 5 } @votes; 
    if ( @votes > 0 and not $c->session->{'growl_suppress'}{'favorites'} ) {
        push @$messages, {
            header  => "Salut,",
            message => "Ai votat ".@votes." bancuri cu 5 stele ! Dacă vrei să le
                        regaseşti in colecţia ta de favorite atunci spune-mi te rog
                        <a href=". $c->uri_for('/auth/form') .">cine eşti</a>.",
            type    => 'favorites',
        }
    }
    
    $c->stash->{'json_growl'} = $messages; 
}

sub suppress :Local {
    my ( $self, $c ) = @_;

    my $type = $c->req->params->{'type'};
    $c->session->{'growl_suppress'}{$type} = 1 if $type;
}

=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
