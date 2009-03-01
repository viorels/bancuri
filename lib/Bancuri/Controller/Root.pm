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
        $c->forward('load_joke', [ $id ]);
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
    my $today = $c->datetime(time_zone=>$c->config->{'time_zone'})->ymd;
    $c->forward('load_joke', [ for_day => $today ]);
    $c->forward($c->controller('Show'));
}

sub load_joke : Private {
    my ( $self, $c, $field, $value ) = @_;
    
    my $joke;
    if ( $field eq 'for_day' ) {
        $joke = $c->model('BancuriDB::Joke')->search_for_day($value, '12:00');
    }
    else {
        $joke = $c->model('BancuriDB::Joke')->find({ $field => $value });
    }

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
		my $url = '/' . $redirect->new_link;
        $c->forward('redirect', [ $url ])
	}
	else {
		$c->forward('not_found', [ $joke_link ]);
	}
}

sub redirect : Private {
    my ( $self, $c, $url, $status ) = @_;
    
	unless ( $url =~ m|^https?://| ) {
	   $url = $c->uri_for( $url );
	};

    unless ( $status ) {
        my $method = $c->request->method;
        if ( $method eq 'GET' ) {
            $status = 301; # Moved Permanently
        }
        elsif ( $method eq 'POST' ) {
            $status = 303; # See Other
        }
        else {
            $status = 302; # Temporary Redirect
        }
    }    
    
	$c->response->redirect( $url, $status );
	$c->detach();
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
