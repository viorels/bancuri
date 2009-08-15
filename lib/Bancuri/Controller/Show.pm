package Bancuri::Controller::Show;

use strict;
use warnings;
use base 'Catalyst::Controller';

use Scalar::Util qw( looks_like_number );
use String::Diff qw( diff_merge );
use Data::Dump qw(pp);

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

=item show_change
Show moderation options, but only if user is logged in.
=cut

sub show_change : Private {
    my ( $self, $c, $version ) = @_;
    my $joke = $c->stash->{'joke'};

    # Only authenticated users are allowed to moderate
	if ( $c->user and my $change = $joke->requires_moderation ) {
	    # Proposed by other then current user ?
        unless ( defined $change->user_id and $change->user_id->id == $c->user->id ) {
            my %change_types = (
                add => 'adaugat',
                edit => 'modificat',
                delete => 'sters',
            );
            
            my $from_text = $change->from ? $change->from->text : '';
            my $to_text = $change->to ? $change->to->text : '';
            my $diff = diff_merge($from_text, $to_text,
                remove_open => '<strike>',
                remove_close => '</strike>',
                append_open => '<strong>',
                append_close => '</strong>',
            );
            
            $c->stash( 
                change => $change,
                change_text => $diff, # TODO | html_entity !!!
                change_type => $change_types{$change->type}, 
            );
        }
	}
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
    	
	    $c->stash( profanity => 1 ) if $joke_version->has_profanity;
    	$c->stash( allow_profanity => 1 ) if $c->user_exists; # TODO and over 18
    }
	# TODO check if there is no such version

    $c->forward('show_change', [$version]);
    $c->forward('show_next_joke');

	$c->stash(
        joke => $joke,
        joke_version => $joke_version,
    );

	$c->stash->{template} = 'joke.html';
}

sub show_next_joke :Private {
    my ($self, $c) = @_;
    
    my $jokes = $c->model('DB::Joke')->search_not_deleted;
    $jokes = $jokes->search_clean if not $c->user or $c->user->is_underage;

    my $next_joke = $jokes->random_beta_single;

    # TODO joke might still have profanity so repeat search a few times
    if ( $next_joke->current->has_profanity ) {
        $c->stash( profanity => 1 );
    }
    
    $c->stash( next_joke => $next_joke );
}

=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
