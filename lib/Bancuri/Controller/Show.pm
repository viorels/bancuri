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
	my $joke_ver = $c->model('BancuriDB::JokeVersion')
		->find({ joke_id => $joke->id, version => $version });
	
	# node_exists ? try redirection ... else show it
    # node is not deleted ?
	# node_required_moderation

#	my $cooked = $wiki->format($node_data{'content'});
	
	$c->stash->{joke} = $joke;
	$c->stash->{joke_ver} = $joke_ver;
	$c->stash->{template} = 'banc.html';
}

sub redirect : Private {
    my ( $self, $c, $id ) = @_;

    $c->response->body("banc id $id"); # TODO redirect to name
}


=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
