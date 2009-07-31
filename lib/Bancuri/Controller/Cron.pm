package Bancuri::Controller::Cron;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use DateTime;
use MIME::Lite::TT::HTML; 

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

    my $latest_joke_for_day = $c->model('DB::Joke')
        ->search({ for_day => { '!=' => undef } }, { order_by => 'for_day desc' })
        ->slice(0, 0)->single;
    my $day = $latest_joke_for_day->for_day;

    my $joke_version = $latest_joke_for_day->current;

    my $users = $c->model('DB::Users')
        ->search_needing_joke_for_day($day);

    while (my $user = $users->next) {
        my $email = $user->email;
        next unless $email;
        
        $c->log->info("sending joke for $day to $email");
        my $msg = MIME::Lite::TT::HTML->new( 
            From        => $c->config->{'webmaster'},
            To          => $email, 
            Subject     => $joke_version->title, 
            Template    => {
                text    => 'joke_for_day.txt',
                html    => 'joke_for_day.html',
            },
            TimeZone    => $c->config->{'time_zone'},
            Charset     => 'utf8',
            TmplOptions => { INCLUDE_PATH => $c->path_to('root', 'email') }, 
            TmplParams  => {
                c       => $c,
                text    => $joke_version->text,
                link    => $c->uri_for("/" . $latest_joke_for_day->link),
            },
        );
        
        $msg->send;
    }
    
    $users->update({ sent_for_day => $day });
    
    $c->response->body('email_joke_for_today');
}


=head2 delete_sessions

=cut

sub delete_sessions :Local :Args(0) {
    my ( $self, $c ) = @_;

    $c->delete_expired_sessions;
    $c->response->body('delete_sessions');
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
