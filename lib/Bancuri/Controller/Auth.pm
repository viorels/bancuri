package Bancuri::Controller::Auth;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use Math::Random qw(random_beta);
use JSON::Any;
use Email::Valid;

require LWP::UserAgent;

=head1 NAME

Bancuri::Controller::Auth - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub form : Local {
    my ( $self, $c ) = @_;
    
    $c->stash(
        current_view => 'TT',
        nowrap => 1,
        template => 'inc/login.html',
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
            my $user = $c->model('BancuriDB::Users')->find({ email => $id });
            if ( $user ) {
                $error = "$id e deja inregistrat";
            }
            elsif ( $password ne $password2 ) {
                $error = "Parolele nu se potrivesc";
            }
            elsif ( not length $name ) {
                $error = "Cum te cheama ?";
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
    
    if ( $c->user ) {
        if ( $c->stash->{'AJAX'} ) {
            $c->stash->{'json_login'} = {
                id => $id,
                name => $c->user->name,
            };
        }
        else {
            $c->forward('/redirect', [ '/' ]);
        }
    }
    else {
        if ( $c->stash->{'AJAX'} ) {
            $c->stash->{'json_error'} ||= 'Ai uitat parola ?';
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
    my $user = $c->model('BancuriDB::Users')->search_email_or_openid($id);
    
    $c->stash->{'json_id_exists'} = $user ? $id : 0;
}

sub rpx : Local {
    my ( $self, $c ) = @_;

    # TODO Fallback to http ?
    my $rest_url = 'https://rpxnow.com/api/v2/auth_info';
    my $token = $c->request->params->{'token'};
    
    my $j = JSON::Any->new;
    my $ua = LWP::UserAgent->new;
    $ua->timeout(10);

    my $response = $ua->post($rest_url, {
        apiKey => 'b5cc4fa0a04cb0c290942a009fa342c17a2d4d00',
        token => $token,
    });
    
    if ( $response->is_success ) {
        my $json = $response->decoded_content;
        $c->log->error( $json );
        my $auth_info = $j->jsonToObj($json);
        if ($auth_info->{'stat'} eq 'ok') {
            my $identifier = $auth_info->{'profile'}{'identifier'};
            my $user = $c->model('BancuriDB::Users')->search_openid($identifier);
            unless ( $user ) {
                $user = $c->forward('register', [ $auth_info->{'profile'} ]);
            }
            $c->forward('login_openid', [ $user ]);
        }
    }
    else {
        $c->log->warn("FAILED $token");
    }
    
    my $back = '/';
    $back = $c->session->{'last_page'} 
        if exists $c->session->{'last_page'};

    $c->forward('/redirect', [ $back ]);
}

sub login_openid : Private {
    my ( $self, $c, $user ) = @_;

    $c->log->debug("LOGIN OPENID ". $user->email);

    # Authenticate user with numeric id (not open id)
    my $authenticated = $c->authenticate( { 
        id => $user->id,
        email => $user->email,
        deleted => 0,
    }, 'passwordless');
    $c->log->warn($authenticated ? "SUCCESS" : "FAILED");
    
    return $c->user;
}

=item register

Register a user (openid). Arguments are RPX stile, e.g. displayName

=cut

sub register : Private {
    my ( $self, $c, $profile ) = @_;
    
    # TODO merge with a possible previous account
    return $c->model('BancuriDB::Users')->register($profile);
}

sub user_info : Private {
    my ( $self, $c ) = @_;
    
    my @teasers = (
        'Login',
        'Nu te cunosc',
        'Spune-mi cine esti',
        'Identifica-te',
        'Eu sunt Bula ... tu ?',
    );
    
    # Beta probability distribution function for a=1, b=2 is f(x) = 2*(1-x) 
    # ... in translation this means that lower numbers are more probable
    my $rand = random_beta(1, 1, 2); # count, a, b
    $rand = int($rand * @teasers); 
    
    $c->stash->{'anonymous'} = $teasers[$rand];
}

sub logout : Local {
    my ( $self, $c ) = @_;
   
    $c->logout();

    # Send the user to the starting point
    unless ( $c->stash->{'AJAX'} ) {
        $c->forward('/redirect', [ '/' ]);
    }
}

=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
