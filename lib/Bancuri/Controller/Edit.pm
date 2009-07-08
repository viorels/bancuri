package Bancuri::Controller::Edit;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

Bancuri::Controller::Edit - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub add : Global {
    my ( $self, $c ) = @_;

    if ( $c->request->method eq 'POST' ) {
        my $joke_text = $c->request->params->{'joke'};
        $c->stash->{'joke'} = $joke_text;

        if ( $c->request->params->{'preview'} ) {
        	# Create a new database object without storing it
            my $new_joke = $c->model('BancuriDB::Joke')->new_result({
                link => undef,
                current => {
                    text => $joke_text, 
                },
            });
            $c->stash->{'joke_preview'} = $new_joke;
        }
        
        if ( $c->request->params->{'save'} ) {
            # TODO check checksum of previous version

            my $user_id = $c->user ? $c->user->id : undef;
            my $browser_id = $c->model('BancuriDB::Browser')->find_or_create_unique(
                $c->sessionid, $c->req->address, $c->req->user_agent)->id;

            my $new_joke = $c->model('BancuriDB::Joke')
                ->add($joke_text, $user_id, $browser_id);
            if ($new_joke) {
                my $link = '/' . $new_joke->link;
                $c->res->redirect($link) and $c->detach;
            }
        }
        
        if ( $c->request->params->{'cancel'} ) {
            my $back = '/';
            $back = $c->session->{'last_page'} 
                if exists $c->session->{'last_page'};

            $c->res->redirect($back) and $c->detach;
        }
    }

    $c->stash->{'template'} = 'add.html';
}

=head2 edit 

=cut

sub edit : Chained('/joke_link') PathPart('edit') Args(0) {
	my ( $self, $c ) = @_;
	my $joke = $c->stash->{'joke'};

	# TODO cook joke content before setting it into <textarea>content<textarea> to avoid "</textarea>"

	my ($joke_text, $joke_title);
	if ( $c->req->method() eq 'GET' ) {
        $joke_text = $joke->current->text;
        $joke_title = $joke->current->title;
	}
	elsif ( $c->req->method() eq 'POST' ) {
        $joke_text = $c->request->params->{'joke'};
        $joke_title = $c->request->params->{'title'};
        my $user_id = $c->user ? $c->user->id : undef;
        my $browser_id = $c->model('BancuriDB::Browser')->find_or_create_unique(
                $c->sessionid, $c->req->address, $c->req->user_agent)->id;
        
        if ( $c->request->params->{'preview'} ) {
        	# Create a new database object without storing it
            my $new_joke = $c->model('BancuriDB::Joke')->new_result({
                link => undef,
                current => {
                    text => $joke_text,
                },
            });
            $c->stash->{'joke_preview'} = $new_joke;
        }
        
        if ( $c->request->params->{'save'} ) {
            $joke->add_version(
                text => $joke_text,
                title => $joke_title,
                parent_version => $joke->version,
                comment => $c->request->params->{'comment'},
                user_id => $user_id,
                browser_id => $browser_id, 
            );
            
            # Redirect to show the (new) joke
            my $link = '/' . $joke->link;
            $c->res->redirect($link) and $c->detach;
        }
        
        if ( $c->request->params->{'delete'} ) {
		    $joke->remove(
                user_id => $user_id,
                browser_id => $browser_id, 		    
                comment => $c->request->params->{'comment'},
		    );
		    
            my $link = '/' . $joke->link;
            $c->res->redirect($link) and $c->detach;
        }
        
        if ( $c->request->params->{'cancel'} ) {
            my $back = '/';
            $back = $c->session->{'last_page'} 
                if exists $c->session->{'last_page'};

            $c->res->redirect($back) and $c->detach;
        }
	}

	$c->stash(
        template => 'edit.html',
		joke => $joke,
		joke_version => $joke->current,
		joke_text => $joke_text,
	   	joke_title => $joke_title,
	   	comment => $c->request->params->{'comment'},
    );
}

sub rating : Local {
	my ( $self, $c ) = @_;
    
    my $id = $c->request->params->{'id'};
    my $vote = $c->request->params->{'rating'};
    
    my $user_id = $c->user ? $c->user->id : undef;
    my $browser_id = $c->model('BancuriDB::Browser')->find_or_create_unique(
            $c->sessionid, $c->req->address, $c->req->user_agent)->id;
                    
    # TODO It's WRONG to assume current version
    my $joke_version = $c->model('BancuriDB::Joke')->find({ id => $id })->current;
    my $new_rating = $joke_version
        ->vote($vote, $user_id, $browser_id);
    
    # XXX undefined means that the user has already voted (today)
    $new_rating = 0 unless defined $new_rating;

    $c->response->body($new_rating);
}

=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
