package Bancuri::Controller::Show;

use strict;
use warnings;
use base 'Catalyst::Controller';

use Scalar::Util qw(looks_like_number);

=head1 NAME

Bancuri::Controller::Show - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub process : Private {
	my ( $self, $c ) = @_;

	$c->forward('current');
}

sub current : Chained('/joke_link') PathPart('') Args(0) {
	my ( $self, $c ) = @_;

	$c->forward('show', []);
}

sub version : Chained('/joke_link') PathPart('v') Args(1) {
    my ( $self, $c, $version ) = @_;

   	$c->forward('show', [ $version ]);
}

sub all_versions : Chained('/joke_link') PathPart('v/all') Args(0) {
    my ( $self, $c ) = @_;

	my $joke = $c->stash->{'joke'};
	my @joke_versions = $joke->search_related('joke_versions')->all();
	
	# TODO move to model
    for my $version ( @joke_versions ) {
        push @{$c->stash->{'json_joke_versions'}}, {
            text => $version->text,
            subject => $version->title,
            title => "Varianta ".$version->version,
            current => $joke->version == $version->version ? 1 : 0,
        };
    };
}

sub show : Private {
	my ( $self, $c, $version ) = @_;
    my $joke = $c->stash->{'joke'};
	
	$c->session->{'last_page'} = $c->request->uri;
	
    my $joke_version;
    unless ($joke->deleted) {
    	if ( looks_like_number $version ) {
    	    $joke_version = $joke->search_related('joke_versions', 
    	       { version => $version })->single;
    	}
    	else {
    	    $joke_version = $joke->current;
    	}
    	
    	if ( $joke_version->has_profanity ) {
    	    $c->stash( profanity => 1 );
    	}
    }

	# TODO check if there is no such version
    # node is not deleted ?
	# node_required_moderation

    my $next_joke = $c->model('BancuriDB::Joke')->search_random_joke()->single();

    if ( $next_joke->current->has_profanity ) {
        $c->stash( profanity => 1 );
    }

	$c->stash(
        joke => $joke,
        joke_version => $joke_version,
        next_joke => $next_joke,
    );

	$c->stash->{template} = 'joke.html';
}

=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
