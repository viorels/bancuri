package Bancuri::Controller::Contact;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use MIME::Lite::TT::HTML;

=head1 NAME

Bancuri::Controller::Contact - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my $text = $c->req->params->{'text'};
    my $email_from = $c->req->params->{'email'};

    if ( $c->req->method eq 'POST' and $text and $email_from ) {
        my $msg = MIME::Lite::TT::HTML->new( 
            From        => $email_from,
            To          => $c->config->{'webmaster'}, 
            Subject     => 'bancuri', 
            Template    => {
                text    => 'contact.txt',
                html    => 'contact.html',
            },
            TimeZone    => $c->config->{'time_zone'},
            Charset     => 'utf8',
            TmplOptions => { INCLUDE_PATH => $c->path_to('root', 'email') }, 
            TmplParams  => {
                text    => $text,
            },
        );
        $msg->send;
        
        $c->stash(text => $text); 
    }

    $c->stash(
        template => 'contact.html',
    );
}

=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
