package Bancuri::Controller::Show;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

Bancuri::Controller::Show - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub process : Private {
	my ( $self, $c ) = @_;

	# / arata bancul zilei
	$c->response->body('Matched Bancuri::Controller::Show');
    
#   Fetch the joke for today and show it's current version
	$c->stash->{'joke_link'} = 'pe-titanic-vine-capitanul-si-spune';
	$c->forward('current');
}

sub current : Chained('/joke') PathPart('') Args(0) {
	my ( $self, $c ) = @_;
	my $joke_link = $c->stash->{'joke_link'};

	# TODO determine current version
	my $version = 1;
	$c->forward('show', [ $joke_link, $version ]);
}

sub ver : Chained('/joke') PathPart Args(1) {
    my ( $self, $c, $version ) = @_;
	my $joke_link = $c->stash->{'joke_link'};

	$c->forward('show', [ $joke_link, $version ]);
}

sub show : Private {
	my ( $self, $c, $joke_link, $version ) = @_;
	
	my $joke = $c->model('BancuriDB::Joke')->find({ link => $joke_link });
	unless ( $joke ) {
		$c->forward('redirect', [ $joke_link ]);
	}

	# TODO check if there are 0 records !
	my $joke_ver = $joke->search_related('joke_versions', { version => $version })->first;
	
#	my $joke_ver = $c->model('BancuriDB::JokeVersion')
#		->find( $joke->id, $version, { key => 'joke_version_pkey' } );
	
	# node_exists ? try redirection ... else show it
    # node is not deleted ?
	# node_required_moderation

#	my $cooked = $wiki->format($node_data{'content'});
	
	$c->stash->{joke} = $joke;
	$c->stash->{joke_ver} = $joke_ver;
	$c->stash->{template} = 'banc.html';
}

sub redirect : Private {
    my ( $self, $c, $joke_link ) = @_;

	my $redirect = $c->model('BancuriDB::Redirect')->find($joke_link);
	if ( $redirect ) {
		my $new_url = $c->uri_for( q{/} . $redirect->new_link );
		my $permanent = 301;
		$c->response->redirect( $new_url, $permanent );
		$c->detach();
	}
	else {
		$c->forward('notfound');
	}
}

sub notfound : Private {
    my ( $self, $c, $joke_link ) = @_;
	
	$c->response->status(404);
	$c->response->body("404 joke not found");
	$c->detach();
}


=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
