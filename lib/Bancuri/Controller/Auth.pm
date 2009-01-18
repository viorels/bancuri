package Bancuri::Controller::Auth;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use Math::Random qw(random_beta);
use JSON::Any;
require LWP::UserAgent;

=head1 NAME

Bancuri::Controller::Auth - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub login : Local {
    my ( $self, $c ) = @_;

    my $authenticated = 0;

    # Get the id and optional password from form
    my $id = $c->request->params->{id} || "";
    my $password = $c->request->params->{password} || "";

    my $type = $c->forward('type', [ $id ]);
    if ( $type eq 'email' and length $password ) {
        $authenticated = $c->authenticate( { 
            email => $id,
            password => $password,
            deleted => 0,
        }, $type);
    };
    
#    if ( $type eq 'openid' ) {
#        $authenticated = $c->authenticate( { 
#            url => $id, 
#            deleted => 0,
#        }, $type);
#    }

    if ( $authenticated ) {
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
       # or undef is authentication failed.  
       # so display the 'try again' page here.
       $c->response->body('Login failed');
    }
}

sub type : Local {
    my ( $self, $c, $id ) = @_;
    
    $c->log->debug("ID ".$id);
    if ( $id =~ /@/ ) {
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
        $c->log->debug( $json );
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
    
    # TODO redirect to last url
    $c->forward('/redirect', ['/']);
}

sub login_openid : Private {
    my ( $self, $c, $user ) = @_;

    $c->log->debug("LOGIN OPENID ". $user->email);

    # Authenticate user with numeric id (not open id)
    my $authenticated = $c->authenticate( { 
        id => $user->id,
        email => $user->email,
        password => $user->password,
        deleted => 0,
    }, 'email');
    $c->log->warn($authenticated ? "SUCCESS" : "FAILED");
    
    return $c->user;
}

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
    );
    
    # Beta probability distribution function for a=1, b=2 is f(x) = 2*(1-x) 
    # ... in translation this means that lower numbers are more probable
    my $rand = random_beta(1, 1, 2); # count, a, b
    $rand = int($rand * @teasers); 
    
    $c->stash->{'anonymous'} = $teasers[$rand];
}

sub logout : Local {
    my ( $self, $c ) = @_;
   
    $c->log->warn("GET /auth/logout") if $c->request->method eq 'GET';

    $c->logout();

    # Send the user to the starting point
    $c->response->redirect($c->uri_for('/'));
}

=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
