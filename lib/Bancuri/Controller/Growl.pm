package Bancuri::Controller::Growl;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use Encode;

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
    
    my @changes = $c->model('DB::Change')->search_for_session($c->sessionid)->all();
    if ( @changes > 0 ) {
        push @$messages, {
            header  => "Salut,",
            message => decode_utf8("Ai făcut ".@changes." modificiari la bancuri !
                        Dacă vrei ca schimbarile să rămână atunci spune-mi te rog
                        <a href=". $c->uri_for('/auth/form') .">cine eşti</a>."),
        }
    }
    
    $c->stash->{'json_growl'} = $messages; 
}

=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
