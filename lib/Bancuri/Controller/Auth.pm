package Bancuri::Controller::Auth;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use Email::Valid;
use utf8;

=head1 NAME

Bancuri::Controller::Auth - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub form : Local {
    my ( $self, $c ) = @_;
    
    my $nowrap = $c->stash->{'AJAX'};

    # TODO embed referer in every /auth/form link
    my $next_page = $c->req->params->{'next_page'}; # XXX unsafe
    $next_page ||= $c->req->referer; # XXX unsafe
    $next_page ||= $c->uri_for('/');
    
    my $rpx_token_url = $c->uri_for('/auth/rpx', { next_page => $next_page }); 
    my $rpx_iframe_url = 'https://bancuri.rpxnow.com/openid/embed';
    $rpx_iframe_url .= '?language_preference=ro';
    $rpx_iframe_url .= '&token_url=' . $rpx_token_url;
    
    $c->stash(
        current_view => 'TT',
        nowrap => $nowrap,
        template => 'inc/login.html',
        login_error => $c->flash->{'login_error'},
        rpx_iframe_url => $rpx_iframe_url,
        next_page => $next_page, # XXX url escape ?
    );
}

sub login : Local {
    my ( $self, $c ) = @_;

    my $id = $c->request->params->{id} || "";
    my $type = $c->forward('type', [ $id ]);

    if ( $type eq 'email' ) {
        my $password = $c->request->params->{password} || "";

        if ( $c->request->params->{'signup'} ) {
            my $password2 = $c->request->params->{'password2'} || "";
            my $name = $c->request->params->{'name'};

            my $error;
            my $user = $c->model('DB::Users')->find({ email => $id });
            if ( $user ) {
                $error = "$id e deja inregistrat";
            }
            elsif ( $password ne $password2 ) {
                $error = "parolele nu se potrivesc !";
            }
            elsif ( not length $name ) {
                $error = "cum te cheamă ?";
            }
            else {
                $user = $c->forward('register', [{
                    email => $id,
                    password => $password,
                    displayName => $name,
                }]);
            }
            $c->stash->{'json_error'} = $error;
        }

        $c->authenticate( { 
            email => $id,
            password => $password,
            deleted => 0,
        }, 'email');

    }
    
    if ( $c->user_exists ) {
        $c->forward('after_login');

        if ( $c->stash->{'AJAX'} ) {
            $c->stash->{'json_login'} = {
                id => $id,
                name => $c->user->nickname,
            };
        }
        else {
            $c->forward('redirect_next');
        }
    }
    else {
        if ( $c->stash->{'AJAX'} ) {
            $c->stash->{'json_error'} ||= 'parola greşită !';
        }
        else {
            $c->flash->{'login_error'} = 'parola greşită !';
            $c->res->redirect('form') && $c->detach;
        }
    }
}

sub type : Local {
    my ( $self, $c, $id ) = @_;
    
    $c->log->debug("ID ".$id);
    if ( Email::Valid->address($id) ) {
        $c->log->debug("EMAIL");
        return 'email';
    }
    else {
        return 'openid';
    }
}

sub id_exists : Local {
    my ( $self, $c ) = @_;

    my $id = $c->request->params->{'id'};
    my $user = $c->model('DB::Users')->search_email_or_openid($id);
    
    $c->stash->{'json_id_exists'} = { $id => $user ? 1 : 0 };
}

sub rpx : Local {
    my ( $self, $c ) = @_;

    my $token = $c->request->params->{'token'};
    
    my $user_data;
    if ($token) {
        $user_data = eval { $c->model('RPX')->auth_info({ token => $token }) };
        $c->log->warn($@) if $@;
    }

    if ( $user_data ) {
        my $identifier = $user_data->{'profile'}{'identifier'};
        my $user = $c->model('DB::Users')->search_openid($identifier);
        unless ( $user ) {
            $user = $c->forward('register', [ $user_data->{'profile'} ]);
        }

        # Authenticate user with numeric id (not open id)
        my $authenticated = $c->authenticate( { 
            id => $user->id,
            email => $user->email,
            deleted => 0,
        }, 'passwordless');
        
        $c->forward('after_login');
    }
    else {
        $c->log->warn("RPX FAILED $token");
    }
    
    $c->forward('redirect_next');
}

sub after_login : Private {
    my ( $self, $c ) = @_;

    $c->user->update_last_login;

    # assign this user to changes made before login
    $c->model('DB::Change')->search_for_session($c->sessionid)
        ->assign_user($c->user->id);

    # assign this user to votes made before login
    $c->model('DB::Vote')->search_for_session($c->sessionid)
        ->assign_user($c->user->id);
    
    return $c->user;
}

=item register

Register a user (openid). Arguments are RPX stile, e.g. displayName

=cut

sub register : Private {
    my ( $self, $c, $profile ) = @_;
    
    # TODO merge with a possible previous account
    return $c->model('DB::Users')->register($profile);
}

sub logout : Local {
    my ( $self, $c ) = @_;

    $c->delete_session('logout');
    $c->forward('redirect_next');
}

sub redirect_next :Local {
    my ( $self, $c ) = @_;
    
    my $next_page = $c->req->params->{'next_page'};
    $next_page ||= $c->uri_for('/'); # just to be safe

    $c->res->redirect($next_page, 302) and $c->detach;
}

=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
