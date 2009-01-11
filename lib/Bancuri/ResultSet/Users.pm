package Bancuri::ResultSet::Users;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

sub search_email_or_openid {
    my ( $self, $id ) = @_;
    
    my $user = $self->find({ email => $id });

    unless ( $user ) {
        $user = $self->search(
            { 'user_openids.identifier' => $id },
            { join => 'user_openids' }
        )->first;
    }

    return $user;
}

sub search_openid {
    my ( $self, $id ) = @_;
    
    my $user = $self->find({ 'user_openids.identifier' => $id }, 
        { join => 'user_openids' });

    return $user;
}

sub register {
    my ( $self, $profile ) = @_;
    
    my $new_user = {
        email => ($profile->{'verifiedEmail'} || $profile->{'email'}),
        password => $profile->{'password'},
        name => $profile->{'displayName'},
        birth => $profile->{'birthday'},
        gender => $profile->{'gender'},
        country => $profile->{'address'}{'country'},
    };
    if ( my $identifier = $profile->{'identifier'} ) {
        $new_user->{'user_openids'} = [
            { identifier => $identifier }
        ];
    }
    
    my $user = $self->create($new_user);

    return $user;
}

1;