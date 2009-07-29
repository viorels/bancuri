package Bancuri::Controller::Feed;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use XML::Feed;

=head1 NAME

Bancuri::Controller::Feed - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->res->redirect($c->uri_for('rss'));
}

=head2 burner
Special url /feed/burner for google/feedburner in order to avoid redirects
=cut

sub burner :Local {
    my ($self, $c) = @_;
    $c->forward('rss');
}

=head2 rss
RSS feed
=cut

sub rss :Local {
    my ($self,$c) = @_;
    $c->forward('jokes_for_days'); # get the entries

    my $feed = XML::Feed->new('RSS'); # or atom ...
    $feed->title( $c->config->{name} . ' RSS Feed' );
    $feed->link( $c->req->base ); # link to the site.
    $feed->description('Bancuri'); 

    # Process the entries
    while( my $entry = $c->stash->{entries}->next ) {
        my $feed_entry = XML::Feed::Entry->new('RSS');
        
        my $text = $entry->current->text_blessed;
        $text =~ s/\n/<br>/g;
        $feed_entry->content( $text );
        
        $feed_entry->title( $entry->current->title );
        $feed_entry->link( $c->uri_for('/', $entry->link) );
        $feed_entry->issued( $entry->for_day );
        $feed->add_entry($feed_entry);
    }
    $c->res->body( $feed->as_xml );
    $c->res->content_type('application/rss+xml');
}

=head2 jokes_for_days
Fill stash with recent jokes of the day (but not from future)
=cut

sub jokes_for_days :Private {
    my ($self, $c) = @_;
    
    $c->stash->{'entries'} = $c->model('DB::Joke')->get_all_for_days();
}


=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
