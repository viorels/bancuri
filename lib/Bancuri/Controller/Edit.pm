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
        my $joke = $c->request->params->{'joke'};
        $c->stash->{'joke'} = $joke;

        if ( $c->request->params->{'preview'} ) {
        	# Create a new database object without storing it
            my $new_joke = $c->model('BancuriDB::Joke')->new_result({
                link => undef,
                current => {
                    text => $joke, 
                },
            });
            $c->stash->{'joke_preview'} = $new_joke;
        }
        
        if ( $c->request->params->{'save'} ) {
            # TODO check checksum of previous version

            my $new_joke = $c->model('BancuriDB::Joke')->add($joke);
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
#                user => ...
#                browser => ...
            );
            
            # Redirect to show the (new) joke
            my $link = '/' . $joke->link;
            $c->res->redirect($link) and $c->detach;
        }
        
        if ( $c->request->params->{'delete'} ) {
		    $joke->remove;
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
    
    # TODO It's WRONG to assume current version
    my $joke_version = $c->model('BancuriDB::Joke')->find({ id => $id })->current;
    my $new_rating = $joke_version
        ->vote($vote, $c->sessionid, $c->req->address, $c->req->user_agent);
    $new_rating = 0 unless defined $new_rating;

    $c->response->body($new_rating);
}

=item change_vote
Vote the change specified by id with -5/+5
Return JSON with ... ?
=cut

sub change_vote : Local {
    my ( $self, $c ) = @_;
    
    my $change_id = $c->request->params->{'change_id'};
    my $vote = $c->request->params->{'vote'};
    
    # TODO is he allowed to vote this ?
    my $change = $c->model('BancuriDB::Change')->find($change_id);
    my $new_rating = $change->vote($vote, $c->user->id,
            $c->sessionid, $c->req->address, $c->req->user_agent);
    
    if (defined $new_rating) {
        $c->stash( json_change_rating => $new_rating );
    }
    else {
        $c->stash( json_change_error => 'Ai mai votat ?' );
    }
}

=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
