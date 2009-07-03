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

sub begin : Private {
    my ( $self, $c ) = @_;
    
    # Called at the beginning of a request, before any matching actions are called.
    # Overrided by child controllers
}

sub auto : Private {
	my ( $self, $c ) = @_;

    $c->forward('redirect_to_www');
	
    # TODO test on IE
    my $req_with = $c->request->header('X-Requested-With');
    if ( $req_with and $req_with eq 'XMLHttpRequest' ) {
        # This is an AJAX request
        $c->log->warn('AJAX');
        $c->stash->{'AJAX'} = $req_with;
    }
    
    $c->forward('/auth/user_info');
    
    return 1;
};

sub default : Path {
	my ( $self, $c ) = @_;
	
	# Called when no other action matches.
	$c->forward('not_found', []);
};

sub index : Path Args(0) {
    my ( $self, $c ) = @_;

	if ( my $id = $c->request->params->{id} ) {
        $c->forward('load_joke', [ link => $id ]);
	}
	# Redirect for legacy search
	elsif ( my $keywords = $c->request->params->{'cautare'} ) {
	    my $start = $c->request->params->{'start'};
	    my $page = $start ? $start/10 + 1 : undef;

		my $new_link = $c->uri_for('/search', $keywords, $page);
        $c->res->redirect($new_link) and $c->detach;	    
	}
	else {
	    $c->forward('joke_for_today');
	}
}

sub joke_link : Chained('/') PathPart('') CaptureArgs(1) {
	my ( $self, $c, $link ) = @_;
	$c->forward('load_joke', [ link => $link ]);
}

sub joke_id : Path('id') Args(1) {
    my ( $self, $c, $id ) = @_;
    $c->forward('load_joke', [ id => $id ]);
    $c->forward($c->controller('Show'));
}

sub joke_for_today : Private {
    my ( $self, $c ) = @_;
    my $tz = $c->config->{'time_zone'};

    my $today = $c->datetime( time_zone => $tz )->ymd;
    my $joke = $c->model('BancuriDB::Joke')->get_for_day($today)
        || $c->model('BancuriDB::Joke')->set_for_day($today);

    $c->stash->{'joke'} = $joke;
    $c->forward($c->controller('Show'));
}

=item load_joke

Load a joke using a criterion like id, link or for_day.
It tries to redirect for links (that includes legacy ids).

=cut

sub load_joke : Private {
    my ( $self, $c, $field, $value ) = @_;
    
    my $joke = $c->model('BancuriDB::Joke')->find({ $field => $value });

	unless ( $joke ) {
	    if ( $field eq 'link' ) {
	        $c->forward('redirect_joke', [ $value ]);
	    }
	    else {
	        $c->forward('not_found', []);
	    }
	}
	
	$c->stash->{'joke'} = $joke;
}

sub redirect_joke : Private {
    my ( $self, $c, $joke_link ) = @_;
    
	my $redirect = $c->model('BancuriDB::Redirect')->find($joke_link);
	if ( $redirect ) {
        # Update last used
        $redirect->last_used('now()');
        $redirect->update();

        # TODO rebuild full link, e.g. /un-banc/edit
		my $new_link = '/' . $redirect->new_link;
        $c->res->redirect($new_link) and $c->detach;
	}
	else {
		$c->forward('not_found', [ $joke_link ]);
	}
}

sub redirect_to_www : Private {
    my ( $self, $c ) = @_;

    if ( $c->req->uri->host eq 'bancuri.com' && $c->req->method ne "POST" ) {
        my $uri = $c->req->uri->clone;
        $uri->host('www.' . $uri->host);
        $c->log->info("Redirect to $uri");
        $c->res->redirect($uri, 301) && $c->detach;
    }
}

sub not_found : Private {
    my ( $self, $c, $joke_link ) = @_;
    
	$c->response->status(404);
	# TODO add search link with words in $joke_link
	$c->response->body("404 Joke not found. Try searching !");
	$c->detach();
}

sub blog : Local {
    my ( $self, $c ) = @_;
    $c->stash->{'template'} = 'blog.html';
}

sub contact : Global {
    my ($self, $c) = @_;
    
    $c->stash( 
        template => 'contact.html',
    );
}

sub end : ActionClass('RenderView') {
	my ( $self, $c ) = @_;
	
    # do stuff here; the RenderView action is called afterwards
    
    if ( $c->stash->{'AJAX'} and not exists $c->stash->{'current_view'} ) {
       	$c->stash->{'current_view'} = 'JSON';
    }
}

=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
