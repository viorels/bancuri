package Bancuri::Schema::ResultSet::Users;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

sub search_email_or_openid {
    my ( $self, $id ) = @_;
    
    my $user = $self->find({ email => $id });
    $user = $self->search_openid($id) unless $user;

    return $user;
}

sub search_openid {
    my ( $self, $id ) = @_;
    
    my $user = $self->find({ 'user_openids.identifier' => $id }, 
        { join => 'user_openids' });

    return $user;
}

=item register
Assume nothing ! It can be an email user or openid user.
=cut

sub register {
    my ( $self, $profile ) = @_;
    
    my $email = $profile->{'verifiedEmail'} || $profile->{'email'};
    my $identifier = $profile->{'identifier'};
    
    my $existing_user = $self->find({ email => $email });

    my $new_user = {
        email => $email,
        password => $profile->{'password'},
        name => $profile->{'displayName'},
        birth => $profile->{'birthday'},
        gender => $profile->{'gender'},
        country => $profile->{'address'}{'country'},
    };
    
    my $registered_user;    
    unless ($existing_user) {
        if ( $identifier ) {
            $new_user->{'user_openids'} = [
                { identifier => $identifier }
            ];
        }
        
        $registered_user = $self->create($new_user);
    }
    else {
        if ( $identifier ) {
            $existing_user->create_related('user_openids', {
                identifier => $identifier,
            })
            # TODO update profile also ?
        }
        
        $registered_user = $existing_user;
        
    }

    return $registered_user;
}


1;
