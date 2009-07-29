package Bancuri::Controller::Cron;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use DateTime;
use Email::Stuff;

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

    my $latest_joke_for_day = $c->model('BancuriDB::Joke')
        ->search({ for_day => { '!=' => undef } }, { order_by => 'for_day desc' })
        ->slice(0, 0)->single;
    my $day = $latest_joke_for_day->for_day;

    my $joke_version = $latest_joke_for_day->current;
    my $text = $joke_version->text . "\n"
        . $c->uri_for("/" . $latest_joke_for_day->link);

    my $users = $c->model('BancuriDB::Users')
        ->search_needing_joke_for_day($day);

    while (my $user = $users->next) {
        my $email = $user->email;
        next unless $email;
        
        $c->log->info("sending joke for $day to $email");
        Email::Stuff->from($c->config->{'webmaster'})
            ->to($email)
            ->subject($joke_version->title)
            ->text_body($text)
            ->send;
    }
    
    $users->update({ sent_for_day => $day });
    
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
