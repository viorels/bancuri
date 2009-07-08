package Bancuri::Controller::Moderate;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

Bancuri::Controller::Moderate - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Bancuri::Controller::Moderate in Moderate.');
}

=item change_vote
Vote the change specified by id with -5/+5
Return JSON with ... ?
=cut

sub change_vote : Local {
    my ( $self, $c ) = @_;
    
    my $change_id = $c->request->params->{'change_id'};
    my $vote = $c->request->params->{'vote'};
    
    my $user_id = $c->user ? $c->user->id : undef;
    my $browser_id = $c->model('BancuriDB::Browser')->find_or_create_unique(
            $c->sessionid, $c->req->address, $c->req->user_agent)->id;
                
    # TODO is he allowed to vote this ?
    my $change = $c->model('BancuriDB::Change')->find($change_id);
    my $new_rating = $change->vote($vote, $user_id, $browser_id);
    my $approved = $change->decide;

    my $message = '';
    if ( defined $new_rating ) {
        my $you_agree = $vote * $new_rating > 0;
        $message = $you_agree ? 'Esti de acord cu majoritatea.'
                : 'Majoritatea nu este de acord cu tine.';
    }
    else {
        $message = 'Ai mai votat ?';
    };
    if ( defined $approved ) {
        $message .= $approved ? ' S-a aprobat !' : ' S-a anulat !'; 
    }
    
    $c->stash( json_change_msg => $message );
}

=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
