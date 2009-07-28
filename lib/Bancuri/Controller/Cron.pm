package Bancuri::Controller::Cron;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use DateTime;

=head1 NAME

Bancuri::Controller::Cron - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 email_joke_for_today

=cut

sub email_joke_for_today :Local :Args(0) {
    my ( $self, $c ) = @_;

    my $today_gmt = DateTime->now->ymd;
    my $users = $c->model('BancuriDB::Users')->search_needing_email();

    while (my $user = $users->next) {
        # send email
    }
    
    $users->update({ sent_for_day => $today_gmt });
    
    $c->response->body('email_joke_for_today');
}


=head2 delete_sessions

=cut

sub delete_sessions :Local :Args(0) {
    my ( $self, $c ) = @_;

    $c->delete_expired_sessions;
}

=head2 rebuild_search_index

=cut

sub rebuild_search_index :Local :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('rebuild_search_index');
}

=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
