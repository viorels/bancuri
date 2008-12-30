package Bancuri::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller';

__PACKAGE__->config->{namespace} = '';

=head1 NAME

Bancuri::Controller::Root - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub auto : Private {
	my ( $self, $c ) = @_;

    return 1;
};

sub default : Path('') {
	my ( $self, $c ) = @_;
	
	$c->response->status(404);
	$c->response->body("404 Not Found");
	$c->request->action(undef);
};

=head2 index 

=cut

sub index : Private {
    my ( $self, $c ) = @_;

	if ( my $id = $c->request->params->{id} ) {
        $c->stash->{'joke_link'} = $id;
        $c->forward(qw/Bancuri::Controller::Show current/);
	}
	else {
        # / arata bancul zilei
		$c->forward('Bancuri::Controller::Show');
	}
}

sub joke : Chained PathPart('') CaptureArgs(1) {
	my ( $self, $c, $joke_link ) = @_;
	$c->stash->{'joke_link'} = $joke_link;
}

sub blog : Global {
    my ( $self, $c ) = @_;
    $c->stash->{'template'} = 'blog.html';
}

sub end : ActionClass('RenderView') {
	my ( $self, $c ) = @_;
    # do stuff here; the RenderView action is called afterwards
}

=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
