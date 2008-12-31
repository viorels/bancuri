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

#   Fetch the joke for today and show it's current version
	$c->stash->{'joke_link'} = '1';
	$c->forward('current');
}

sub current : Chained('/joke') PathPart('') Args(0) {
	my ( $self, $c ) = @_;
	my $joke_link = $c->stash->{'joke_link'};

	$c->forward('show', [ $joke_link, undef ]);
}

sub version : Chained('/joke') PathPart('v') Args(1) {
    my ( $self, $c, $version ) = @_;
	my $joke_link = $c->stash->{'joke_link'};

    if ( $version =~ /[0-9]+/ ) {
    	$c->forward('show', [ $joke_link, $version ]);
    }
    else {
        $c->forward('all_versions', [ $joke_link ]);
    }
}

sub all_versions : Private {
    my ( $self, $c, $joke_link ) = @_;

	my $joke = $c->model('BancuriDB::Joke')->find({ link => $joke_link });
	my @joke_versions = $joke->search_related('joke_versions')->all();
    for my $version ( @joke_versions ) {
        push @{$c->stash->{'json_joke_versions'}}, {
            text => $version->text,
            subject => $version->title,
            title => "Varianta ".$version->version,
            current => $joke->version == $version->version ? 1 : 0,
        };
    };
    $c->forward('Bancuri::View::JSON');
}

sub show : Private {
	my ( $self, $c, $joke_link, $version ) = @_;
	
	my $joke = $c->model('BancuriDB::Joke')->find({ link => $joke_link });
	unless ( $joke ) {
		$c->forward('redirect', [ $joke_link ]);
	}

	my $joke_ver;
	if ( not defined $version or $joke->version == $version ) {
		$joke_ver = $joke->current_version;
        $version = $joke_ver->version;
	}
	else {
		# TODO check if there are no records !
		$joke_ver = $joke->search_related('joke_versions', { version => $version })->first;
#		$joke_ver = $c->model('BancuriDB::JokeVersion')
#			->find( $joke->id, $version, { key => 'joke_version_pkey' } );
	}

    my $next_joke = $c->model('BancuriDB::Joke')->search_random_joke();
	
    # node is not deleted ?
	# node_required_moderation

    # TODO rename 'title' to 'subject'

	$c->stash({
        joke => $joke,
        joke_ver => $joke_ver,
        next_joke => $next_joke,
    });

	$c->stash->{template} = 'banc.html';
}

sub redirect : Private {
    my ( $self, $c, $joke_link ) = @_;
    
	my $redirect = $c->model('BancuriDB::Redirect')->find($joke_link);
	if ( $redirect ) {
        # Update last used
        $redirect->last_used('now()');
        $redirect->update();

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
