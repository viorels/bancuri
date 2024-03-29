package Bancuri::Controller::Edit;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use Digest::SHA qw(sha1_hex);
use List::MoreUtils qw(any);

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
        $joke_text =~ s/\r\n|\n|\r/\n/g; # convert dos/mac terminators to unix
        $c->stash->{'joke'} = $joke_text;

        if ( $c->request->params->{'preview'} ) {
        	# Create a new database object without storing it
            my $new_joke = $c->model('DB::Joke')->new_result({
                link => undef,
                current => {
                    text => $joke_text, 
                },
            });
            $c->stash->{'joke_preview'} = $new_joke;
        }
        
        if ( $c->request->params->{'save'} ) {
            $c->session unless $c->sessionid; # init session

            my $user_id = $c->user_exists ? $c->user->id : undef;
            my $browser_id = $c->model('DB::Browser')->find_or_create_unique(
                $c->sessionid, $c->req->address, $c->req->user_agent)->id;

            my $new_joke = $c->model('DB::Joke')
                ->add($joke_text, $user_id, $browser_id);

            if ($new_joke) {
                my $link = '/' . $new_joke->link;
                $c->res->redirect($link) and $c->detach;
            }
        }
        
        if ( $c->request->params->{'cancel'} ) {
            my $back = '/';
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

	# TODO cook joke content before setting it into <textarea>content<textarea> 
	# to avoid XSS, e.g. "</textarea>"

	my ($joke_text, $joke_title);
	if ( $c->req->method() eq 'GET' ) {
        $joke_text = $joke->current->text;
        $joke_title = $joke->current->title;
        
	    $c->stash( profanity => 1 ) if $joke->current->has_profanity;
    	$c->stash( allow_profanity => 1 ) if $c->user_exists; # TODO and over 18    	
	}
	elsif ( $c->req->method() eq 'POST' ) {
        $joke_text = $c->request->params->{'joke'};
        $joke_text =~ s/\r\n|\n|\r/\n/g; # convert dos/mac terminators to unix
        $joke_title = $c->request->params->{'title'};
        
        $c->session unless $c->sessionid; # init session
        
        my $user_id = $c->user_exists ? $c->user->id : undef;
        my $browser_id = $c->model('DB::Browser')->find_or_create_unique(
                $c->sessionid, $c->req->address, $c->req->user_agent)->id;
        
        if ( $c->request->params->{'preview'} ) {
        	# Create a new database object without storing it
            my $new_joke = $c->model('DB::Joke')->new_result({
                link => undef,
                current => {
                    text => $joke_text,
                },
            });
            $c->stash->{'joke_preview'} = $new_joke;
        }
        
        if ( $c->request->params->{'save'} ) {
            if (sha1_hex($joke_text) ne $joke->current->text_sha1
                or $joke_title ne $joke->current->title) {
                $joke->add_version(
                    text => $joke_text,
                    title => $joke_title,
                    parent_version => $joke->version,
                    comment => $c->request->params->{'comment'},
                    user_id => $user_id,
                    browser_id => $browser_id, 
                );
            }
        }
        
        if ( $c->request->params->{'delete'} ) {
		    $joke->remove(
                user_id => $user_id,
                browser_id => $browser_id, 		    
                comment => $c->request->params->{'comment'},
		    );
        }
        
        if ( any { exists $c->request->params->{$_} } qw(save delete cancel) ) {
            my $link = '/' . $joke->link;
            $c->res->redirect($link) and $c->detach;
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
    
    $c->session unless $c->sessionid; # init session
    
    my $user_id = $c->user_exists ? $c->user->id : undef;
    my $browser_id = $c->model('DB::Browser')->find_or_create_unique(
            $c->sessionid, $c->req->address, $c->req->user_agent)->id;

    # TODO implement vote canceling ($vote == 0)
 
    my $new_rating;
    if ($id) {
        # TODO It's WRONG to assume current version
        my $joke_version = $c->model('DB::Joke')->find({ id => $id })->current;
        if ($joke_version && $vote) {
            $new_rating = $joke_version->vote($vote, $user_id, $browser_id);
        }
    }
    
    # undefined means that the user has already voted (today)
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
